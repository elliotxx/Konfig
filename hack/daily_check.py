import os
import requests
import time
import json

CHECK_INTERVAL = os.getenv("CHECK_INTERVAL", 600)  # 检查流水线的时间范围，默认为执行时间前10分钟之内
PRIVATE_TOKEN = os.getenv("PRIVATE-TOKEN")


def get_latest_pipelines(page):
    headers = {'PRIVATE-TOKEN': PRIVATE_TOKEN}
    url = 'https://code.alipay.com/api/v3/projects/132634/pipelines?ref=master&page=' + str(page)
    get_result = requests.get(url, headers=headers)
    print(f'>> Result: {get_result.text}')
    return get_result


def check_pipelines(pipelines):
    failed_pipelines = []
    for pipeline in pipelines:
        finished_time = time.mktime(time.strptime(pipeline.get('finished_at'), '%Y-%m-%dT%H:%M:%S+08:00'))
        if local_time - finished_time > CHECK_INTERVAL:
            break
        if pipeline.get('status') == 'failed':
            print(f'>> Found Failed Pipeline: https://code.alipay.com/sigma/Konfig/pipelines/{pipeline.get("id")}')
            failed_pipelines.append(pipeline)
    return failed_pipelines


if __name__ == '__main__':
    local_time = time.time()
    print(f'>> local_time: {local_time}')
    page = 1
    result = get_latest_pipelines(page)
    pipelines = json.loads(result.text).get('list')
    last_finished_time = time.mktime(time.strptime(pipelines[-1].get('finished_at'), '%Y-%m-%dT%H:%M:%S+08:00'))
    while local_time - last_finished_time < CHECK_INTERVAL:
        print(f'>> last_finished_time: {last_finished_time}')
        page += 1
        result = get_latest_pipelines(page)
        pipelines.extend(json.loads(result.text).get('list'))
        last_finished_time = time.mktime(time.strptime(pipelines[-1].get('finished_at'), '%Y-%m-%dT%H:%M:%S+08:00'))
    check_result = check_pipelines(pipelines)
    if len(check_result) > 0:
        raise Exception(f'Found failed pipelines on master branch: {check_result}')
