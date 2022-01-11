import os
import sys
import time
import requests
import yaml
import subprocess
from lib.common import *
from lib import utils
from pathlib import Path
from urllib.parse import quote_plus
import signal
import re

zappinfo_domain = os.getenv("ZAPPINFO_DOMAIN")
zappinfo_token = os.getenv("ZAPPINFO_TOKEN")
# todo import inputs in plugins & .aci.yml
code_domain = "https://code.alipay.com"
code_token = os.getenv("ACI_VAR_gtoken")

MAX_RETRY_COUNT = 3
MAX_WAIT_TIME = 5
tags = []
projects = []
commit_timestamp = subprocess.check_output('git log --pretty=format:"%ct" HEAD -1', shell=True)
timestamp = time.strftime("%Y%m%d%H%M%S", time.gmtime(float(commit_timestamp) + 8 * 60 * 60))
old_version = 1
ppl_url = os.getenv("ACI_PIPELINE_URL")
# 获取仓库名称 e.g. sigma/Konfig
code_names = re.findall(r"https?://\S+/(\S+)/(\S+).git", os.getenv("ACI_REPOSITORY_URL"), re.M)[0]
code_project_name = code_names[0]+'/'+code_names[1]


def init():
    os.system('git config --global user.email "$ACI_VAR_git_user@alipay.com"')
    os.system('git config --global user.name "$ACI_VAR_git_user"')


def is_path_change(project_name, path):
    url = zappinfo_domain + "/openapi/rest/appConfig/query.json?appName=" + project_name + "&configType=IAC_CONFIG&configProperty=IAC_CONFIG_PATH"
    headers = {'x-apiauth-token': zappinfo_token}
    resp = requests.get(url, headers=headers).json()
    print("is_path_change result-code: " + resp['resultCode'])
    if resp['resultCode'] == 'SUCCESS':
        target = resp['target']
        if target is not None:
            if len(target) > 0:
                global old_version
                old_version = target[0]['version']
                old_path = target[0]['configValue']
                if path == old_path:
                    return False
        return True
    print("[fatal] query iac path in zappinfo failed! appName = {}".format(project_name))
    sys.exit(1)


def is_tag_existed(name):
    url = code_domain + "/api/v3/projects/" + quote_plus(code_project_name.encode('utf-8')) + "/repository/tags_names"
    headers = {'PRIVATE-TOKEN': code_token, 'accept': 'application/json'}
    resp = requests.get(url, headers=headers).json()
    return name in resp


def is_release_branch_existed(branch_name):
    url = code_domain + "/api/v3/projects/" + quote_plus(code_project_name.encode('utf-8')) + "/repository/branches/" + branch_name
    headers = {'PRIVATE-TOKEN': code_token, 'accept': 'application/json'}
    resp = requests.get(url, headers=headers).json()
    return 'commit' in resp


def update_iac_path_info(name, path, version):
    url = zappinfo_domain + "/openapi/rest/appConfig/updateAppConfig.json"
    headers = {'x-apiauth-token': zappinfo_token, 'accept': 'application/json'}
    formate = {
        "appName": name,
        "configType": "IAC_CONFIG",
        "configProperty": "IAC_CONFIG_PATH",
        "configValue": path,
        "version": version
    }
    resp = requests.post(url, data=formate, headers=headers).json()
    print("upate iac path result-code: " + resp['resultCode'])
    if not resp['resultCode'] == 'SUCCESS':
        print("[fatal] update iac path info in zappinfo failed! appName = {}, path = {}, version = {}".format(name, path, version))
        sys.exit(1)


def sync_app_path_info(name, path):
    if not is_path_change(name, path):
        print("path not changed: " + path)
        return
    if old_version is not None:
        version = old_version
    else:
        version = 1
    update_iac_path_info(name, path, version)


def get_auth_git_url():
    url = os.getenv("ACI_REPOSITORY_URL")
    protocol = url.split("//")[0]
    addr = url.split("//")[1]
    return protocol + "//" + os.getenv("ACI_VAR_git_user") + ":" + os.getenv("ACI_VAR_gtoken") + "@" + addr


# timer --  setting timeout
def timeout_handler(signum, frame):
    raise Exception('execute timeout ,the timeout is :', MAX_WAIT_TIME)


# create tag & push
def create_tag(name):
    print("ready to create tag " + name)
    if is_tag_existed(name):
        print("tag is already exist. continue")
        return
    tag_res = os.system('git tag ' + name + ' -m "Detected code change merged into master,create tag auto by pipeline ' + ppl_url + '"')
    push_res = os.system('git push ' + get_auth_git_url() + " " + name)
    if not (tag_res == 0 and push_res == 0):
        # print("[fatal] create tag failed! tagName = {}".format(name))
        raise Exception("[fatal] create tag failed! tagName = {}".format(name))
    print("create tag success: " + name)
    return


# create branch & push
def create_branch(name):
    print("ready to create branch " + name)
    branch_name = "release-" + name
    if is_release_branch_existed(branch_name):
        print("release branch is already exist. continue")
        return
    create_branch_res = os.system('git branch ' + branch_name)
    push_res = os.system('git push ' + get_auth_git_url() + " " + branch_name)
    if not (create_branch_res == 0 and push_res == 0):
        # print("[fatal] create release branch failed! branchName = {}".format(branch_name))
        raise Exception("[fatal] create release branch failed! branchName = {}".format(branch_name))
    print("create branch success: " + name)
    return


# execute func with timeout alarm
def exec_with_timeout(func, arg):
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(MAX_WAIT_TIME)
    try:
        func(arg)
    except Exception as exc:
        raise exc
    finally:
        signal.alarm(0)


# execute function with retry
def exec_with_retry(func, arg, retry_desc):
    retry_cnt = 0
    execute_success = False
    # handle hang retry and fail retry
    while not execute_success and retry_cnt <= MAX_RETRY_COUNT:
        try:
            if retry_cnt > 0:
                print('[retry-times: {}]'.format(retry_cnt), retry_desc)
            exec_with_timeout(func, arg)
            execute_success = True
        except Exception as exc:
            retry_cnt += 1
            print(exc)
    assert execute_success, '[fatal] ' + retry_desc


# Get the path between "sigma" and ProjectDir,
# this is IAC Config Path in zappinfo
def get_middle_path(project_dir: Path) -> str:
    konfig_root = utils.get_konfig_root()
    sigma_root = konfig_root
    return str(project_dir.relative_to(sigma_root).parent)


def get_project_name(file_path: str) -> str:
    print(file_path)
    if os.path.exists(file_path):
        with open(file_path) as file:
            return yaml.load(file, Loader=yaml.FullLoader).get("name")
    return "facke-project-name"


if __name__ == '__main__':
    init()

    file_diff = ''
    aci_commit_start_sha = os.getenv("ACI_COMMIT_START_SHA")
    if not aci_commit_start_sha:
        print("EMPTY ACI_COMMIT_START_SHA, USE CHANGED_FILE_LIST_URL INSTEAD")
        changed_file_list_url = os.getenv('CHANGED_FILE_LIST_URL', '')
        file_diff = utils.get_changed_files_from_oss(changed_file_list_url)
    else:
        out = os.popen("git diff -M --color --name-only $ACI_COMMIT_START_SHA...$ACI_COMMIT_SHA | cat")
        file_diff = out.read()
    files = file_diff.split('\n')
    print("diff files:")
    print(file_diff)

    konfig_root = utils.get_konfig_root()
    for diff_file in files:
        project_dir = utils.get_project_root(konfig_root / diff_file)
        # not a project path
        if project_dir is None:
            continue
        if utils.startswith(project_dir, konfig_root):
            if utils.startswith(project_dir, konfig_root / "base"):
                # process /base
                project_name = "base"
                tag_name = project_name + "-" + timestamp
                if tag_name not in tags:
                    tags.append(tag_name)
            else:
                # process /* (exclude /base)
                project_name = get_project_name(str(project_dir / PROJECT_FILE))
                tag_name = project_name + "-" + timestamp
                if tag_name not in tags:
                    tags.append(tag_name)
                    projects.append(project_name + "-" + timestamp + "#/" + str(project_dir.relative_to(konfig_root)))
                    sync_app_path_info(project_name, get_middle_path(project_dir))

    for tag_name in tags:
        exec_with_retry(create_tag, tag_name, "create tag timeout")
        exec_with_retry(create_branch, tag_name, "create branch timeout")
        # create_tag(tag_name)
        # create_branch(tag_name)

    print('add_output changedApps ' + ';'.join(projects))
    os.system('add_output changedApps ' + '"' + ';'.join(projects) + '"')
