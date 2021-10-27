schema relaxed BizMixin:
    __biz_labels: {str:str} = {
        "app": metadata.__META_APP_NAME
        "env": metadata.__META_ENV_TYPE_NAME
        "cluster": metadata.__META_CLUSTER_NAME
    }

    __biz_selector: {str:str} = __biz_labels

    __biz_envs: [{str:}] = [
        {
            name: "app"
            value: metadata.__META_APP_NAME
        }
        {
            name: "env"
            value: metadata.__META_ENV_TYPE_NAME
        }
        {
            name: "cluster"
            value: metadata.__META_CLUSTER_NAME
        }
    ]
    