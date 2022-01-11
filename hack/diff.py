import datetime
import json
import os
from json import JSONDecodeError

import yaml
import requests
import sys
from pathlib import Path
from lib import utils

from lib.ansi2html.converter import Ansi2HTMLConverter

DIFF = "diff"
CHANGED_FILE_LIST_URL = os.getenv('CHANGED_FILE_LIST_URL', '')
CHANGED_APPS = os.getenv("CHANGED_APPS", "")
OPERATOR = os.getenv("OPERATOR", "system")
GIT_REPO = os.getenv("GIT_REPO", "git@code.alipay.com:sigma/Konfig.git")
BASE_DIRS = ['base']
WHITE_LIST = ['antmonitor','siteops']
ROOT_STR = ""
ROOT = Path(ROOT_STR)

print("CHANGED_FILE_LIST_URL=" + CHANGED_FILE_LIST_URL)
print("CHANGED_APPS=" + CHANGED_APPS)
print("OPERATOR=" + OPERATOR)


def process_changed_providers(func):
    change_file_list = utils.get_changed_files_from_oss(CHANGED_FILE_LIST_URL)
    print("CHANGED_FILE_LIST=" + change_file_list)
    if not change_file_list or change_file_list == "zz_default_change_list_value":
        print("EMPTY_CHANGE_LIST")
        return "EMPTY_CHANGE_LIST"
    else:
        stack_dirs = get_stack_files_paths_from_change_paths(change_file_list)
        r = process(stack_dirs, func)
        r = r.replace("'", "\'")
        print("result: " + r)
        os.system("add_output diffDetail " + "'" + r + "'")
        return r


def get_stack_files_paths_from_change_paths(change_paths_str):
    stack_files = []
    base_dir_str_list = [str(ROOT.joinpath(v)) for v in BASE_DIRS]
    change_paths = change_paths_str.split("\n")
    for change_path in change_paths:
        if any([change_path.startswith(base_dir_prefix) for base_dir_prefix in base_dir_str_list]):
            continue
        elif not change_path:
            continue
        elif all(k not in change_path for k in WHITE_LIST):
            print("not match any provider in white_list:" + ''.join(WHITE_LIST) + ", skip this file: " + change_path)
            continue
        elif not change_path.endswith("stdout.golden.yaml"):
            print("not match any provider, skip this file: " + change_path)
            continue
        # find nearest stack.yaml
        splits = change_path.split("/")
        path = change_path
        for index in range(len(splits) - 1):
            path = path.rsplit('/', 1)[0]
            if not path:
                continue
            if path and find_in_dirs(path, "stack.yaml"):
                if path not in stack_files:
                    stack_files.append(path)
                break
    return stack_files


def find_in_dirs(path, file_name):
    dir_path = Path(path)
    if dir_path.exists():
        for filename in os.listdir(path):
            if filename.lower() == file_name:
                stack_path = os.path.join(path, filename)
                print("find " + stack_path)
                return stack_path
    return ""


def parse_project_yaml(stack_path):
    splits = stack_path.split("/")
    path = stack_path
    yaml_map = {}
    for _ in range(len(splits) - 1):
        path = path.rsplit('/', 1)[0]
        if not path:
            continue
        target_file = find_in_dirs(path, "project.yaml")
        if target_file:
            with open(target_file, 'r') as stream:
                try:
                    yaml_map = yaml.safe_load(stream)
                except yaml.YAMLError as exc:
                    print(exc)
                    sys.exit(1)
            return yaml_map

    return yaml_map


def process(stack_dirs, request_func):
    diff_result = ''
    for stack_dir in stack_dirs:
        # find nearest project
        yaml_map = parse_project_yaml(stack_dir)
        yaml_map["revision"] = parse_tag(yaml_map["name"])
        yaml_map["operator"] = OPERATOR
        yaml_map["repo"] = GIT_REPO
        yaml_map["globalTenant"] = yaml_map["tenant"]
        yaml_map["project"] = yaml_map["name"]
        headers = {'Content-type': 'application/json'}
        print("request by stack:" + stack_dir)

        for root, dirs, files in os.walk(stack_dir):
            for name in files:
                if name == 'main.k':
                    print("find main.k in path:" + root)
                    kcl_build_options = {
                        "settings": ["kcl.yaml"],
                        "disable_none": True,
                        "workdir": root,
                        "arguments": ["__konfig_output_format__=pretty"]
                    }
                    yaml_map["kcl_build_options"] = kcl_build_options
                    data_json = json.dumps(yaml_map)
                    print("request data:", data_json)
                    print("request time:", datetime.datetime.now())
                    response = requests.post("http://infracore-pre.alipay.com:8080/api/v1/release/%s" % request_func,
                                             data=data_json, headers=headers)
                    print("status_code: " + str(response.status_code) + ", reason: " + response.reason)
                    if response.status_code != 200:
                        print(f"{request_func} request failed!!!")
                        print(f"request text: {response.text}")
                        exit(1)
                    try:
                        json_data = response.json()
                    except JSONDecodeError as e:
                        print(f"JSONDecodeError!!! {e}")
                        exit(1)

                    ip = json_data["ip"]
                    print("IP: ", ip)
                    data = json_data["data"]
                    print("Data:")
                    print(data)
                    if type(data) == str:
                        if not data:
                            if data[0] == "\"":
                                data = data[1:len(data)]
                            if data[len(data) - 1] == "\"":
                                data = data[:len(data) - 1]
                        diff_result = diff_result + data + '\n\n'
                    else:
                        diff_result = diff_result + json.dumps(data)
                    break
    conv = Ansi2HTMLConverter()
    html = conv.convert(diff_result)
    print("HTML result:\n" + html)
    return html


def parse_tag(project_name):
    app_path_list = CHANGED_APPS.split(";")
    if not app_path_list:
        print("empty change apps:" + CHANGED_APPS)
        sys.exit(1)
    for path in app_path_list:
        splits = path.split("#")
        if not splits or len(splits) != 2:
            print("illegal app_path:" + path)
            sys.exit(1)
        if splits[0].split("-")[0] == project_name:
            return splits[0]


if __name__ == '__main__':
    process_changed_providers(DIFF)

