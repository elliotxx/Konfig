import base.pkg.kusion_models.kube.frontend.common
import base.pkg.kusion_kubernetes.api.core.v1 as corev1

schema Service(common.Metadata):
    """Service are Kubernetes objects which partition a single 
    Kubernetes cluster into multiple virtual clusters. 

    Attributes
    ----------
    name: str, default is Undefined, required.
        The name of the resource.
        Name must be unique within a namespace. It's required when creating
        resources, although some resources may allow a client to request the
        generation of an appropriate name automatically.
        Name is primarily intended for creation idempotence and configuration
        definition. Cannot be updated. More info:
        http://kubernetes.io/docs/user-guide/identifiers#names
    labels: {str:str}, default is Undefined, optional.
        Labels is a map of string keys and values that can be used to
        organize and categorize (scope and select) objects.
        May match selectors of replication controllers and services.
        More info: http://kubernetes.io/docs/user-guide/labels
    annotations: {str:str}, default is Undefined, optional.
        Annotations is an unstructured key value map stored with a
        resource that may be set by external tools to store and retrieve
        arbitrary metadata. They are not queryable and should be preserved
        when modifying objects.
        More info: http://kubernetes.io/docs/user-guide/annotations
    namespace: str, default is Undefined, optional.
        Namespaces are intended for use in environments with many users spread
        across multiple teams, or projects.
        For clusters with a few to tens of users, you should not need to create
        or think about namespaces at all. Start using namespaces when you need the features they provide.
        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
    ports: [{str:}], default is Undefined, optional.
        The list of ports that are exposed by this service. 
        More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
    selector: {str:str}, default is Undefined, optional.
        Route service traffic to pods with label keys and values matching this selector. 
        If empty or not present, the service is assumed to have an external process managing its endpoints, which Kubernetes will not modify. 
        Only applies to types ClusterIP, NodePort, and LoadBalancer. Ignored if type is ExternalName. 
        More info: https://kubernetes.io/docs/concepts/services-networking/service/
    type: str, default is "ClusterIP", optional.
        determines how the Service is exposed. 
        Defaults to ClusterIP. 
        Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. 
        "ExternalName" maps to the specified externalName. 
        "ClusterIP" allocates a cluster-internal IP address for load-balancing to endpoints. 
        Endpoints are determined by the selector or if that is not specified, by manual construction of an Endpoints object. 
        If clusterIP is "None", no virtual IP is allocated and the endpoints are published as a set of endpoints rather than a stable IP. 
        "NodePort" builds on ClusterIP and allocates a port on every node which routes to the clusterIP. 
        "LoadBalancer" builds on NodePort and creates an external load-balancer (if supported in the current cloud) which routes to the clusterIP. 
        More info: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
        If not specified, default to "ClusterIP".
    clusterIP: str, default is None, optional.
        clusterIP is the IP address of the service and is usually assigned randomly by the master. 
        If an address is specified manually and is not in use by others, it will be allocated to the service; 
        otherwise, creation of the service will fail. 
        This field can not be changed through updates. 
        Valid values are "None", empty string (""), or a valid IP address. 
        "None" can be specified for headless services when proxying is not required. 
        Only applies to types ClusterIP, NodePort, and LoadBalancer. 
        Ignored if type is ExternalName.
        More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
        If not specified, default to Undefined.

    Examples
    --------
    services = Service {
        name: "my-service-name"
        namespace: "my-service-name"
        labels: {
            env: "dev"
        }
        selector: {
            cloudmesh: "pilot-prod"
        }
        ports: [
            {
                name: "grpc-xds"
                port: 15010
            }
            {
                name: "https-xds"
                port: 15011
            }
        ]
    }
    """
    userIdentity?: str
    autoLabel?: bool = False
    selector?: {str:str}
    autoSelector?: bool = True
    ports?: [corev1.ServicePort]
    clusterIP?: str
    type?: str
    externalIPs?: [str]
    externalName?: str
    externalTrafficPolicy?: str
    healthCheckNodePort?: int
    ipFamilyPolicy?: str
    loadBalancerIP?: str
    loadBalancerSourceRanges?: [str]
    publishNotReadyAddresses?: bool
    sessionAffinity?: str
    sessionAffinityConfig?: {str:}
