import base.pkg.kusion_kubernetes.api.core.v1 as kubev1

schema ContainerFrontend2Kube[c]:
    # Kube variable
    _kubeResource?: {str:}
    _kubeEnvList?: [{str:}]
    _kubeEnvFromList?: [{str:}]
    _kubePortList?: [{str:}]
    _kubeReadinessProbe?: {str:}
    _kubeLivenessProbe?: {str:}
    _kubeStartupProbe?: {str:}
    _kubeLifecycle?: {str:}

    # Convert frontend resource to kube resource
    if c?.resource:
        _sidecarResourceLimitsOrRequests = {
            cpu: c.resource.cpu
            memory: c.resource.memory
            "ephemeral-storage": c.resource.disk
        } if typeof(c.resource) == "Resource" else Undefined

        _kubeResource = {
            limits: {
                cpu: c.resource?.limits?.cpu
                memory: c.resource?.limits?.memory
                "ephemeral-storage": c.resource?.limits?.disk
            }
            requests: {
                cpu: c.resource?.requests?.cpu
                memory: c.resource?.requests?.memory
                "ephemeral-storage": c.resource?.requests?.disk
            }
        } if typeof(c.resource) == "ResourceRequirements" else {
            limits: _sidecarResourceLimitsOrRequests
            requests: _sidecarResourceLimitsOrRequests
        }

    # Convert frontend env to kube env
    if c?.env:
        _kubeEnvList = [
            {
                name: e.name
                value: e.value
                valueFrom: {
                    fieldRef: e.valueFrom.fieldRef
                    configMapKeyRef: {
                        name: e.valueFrom.configMapKeyRef.name
                        key: e.valueFrom.configMapKeyRef.key
                    } if e.valueFrom.configMapKeyRef else Undefined
                    secretKeyRef: {
                        name: e.valueFrom.secretKeyRef.name
                        key: e.valueFrom.secretKeyRef.key
                    } if e.valueFrom.secretKeyRef else Undefined
                } if e.valueFrom else Undefined
            } for e in c.env
        ]

    # Convert frontend envFrom to kube envFrom
    if c?.envFrom:
        _kubeEnvFromList = [
            {
                configMapRef: {
                    name: ef.configMapRef
                } if ef.configMapRef else Undefined
                secretRef: {
                    name: ef.secretRef
                } if ef.secretRef else Undefined
            } for ef in c.envFrom
        ]

    # Convert kube ports to kube ports
    if c?.ports:
        _kubePortList = [
            {
                name: port.name
                containerPort: port.containerPort
                protocol: port.protocol
            } for port in c.ports
        ]

    # Convert frontend probe to kube probe
    if c?.readinessProbe or c?.livenessProve or c?.startupProbe:
        _iacProbes = [
            c?.readinessProbe
            c?.livenessProbe
            c?.startupProbe
        ]
        _kubeProbes = [kubev1.Probe {
            exec:                   kubev1.ExecAction {
                command: _iacProbe.handler.command
            } if _iacProbe.handler.type == "exec" else Undefined
            httpGet:                kubev1.HTTPGetAction {
                path: _iacProbe.handler.path
                port: _iacProbe.handler.port
                scheme: _iacProbe.handler.scheme
            } if _iacProbe.handler.type == "http" else Undefined
            tcpSocket:              kubev1.TCPSocketAction {
                port: _iacProbe.handler.tcpSocket
            } if _iacProbe.handler.type == "tcp" else Undefined
            failureThreshold:       _iacProbe.failureThreshold
            initialDelaySeconds:    _iacProbe.initialDelaySeconds
            periodSeconds:          _iacProbe.periodSeconds
            successThreshold:       _iacProbe.successThreshold
            timeoutSeconds:         _iacProbe.timeoutSeconds
        } if _iacProbe else Undefined for _iacProbe in _iacProbes]
        _kubeReadinessProbe = _kubeProbes[0]
        _kubeLivenessProbe = _kubeProbes[1]
        _kubeStartupProbe = _kubeProbes[2]

    # Convert frontend lifecycle to kube lifecycle
    if c?.lifecycle:
        _kubeLifecycle = {
            preStop: {
                exec:                   kubev1.ExecAction {
                    command: c.lifecycle.preStop.command
                } if c.lifecycle.preStop.type == "exec" else Undefined
                httpGet:                kubev1.HTTPGetAction {
                    path: c.lifecycle.preStop.path
                    port: c.lifecycle.preStop.port
                    scheme: c.lifecycle.preStop.scheme
                } if c.lifecycle.preStop.type == "http" else Undefined
                tcpSocket:              kubev1.TCPSocketAction {
                    port: c.lifecycle.preStop.tcpSocket
                } if c.lifecycle.preStop.type == "tcp" else Undefined
            } if c.lifecycle.preStop else Undefined
            postStart: {
                exec:                   kubev1.ExecAction {
                    command: c.lifecycle.postStart.command
                } if c.lifecycle.postStart.type == "exec" else Undefined
                httpGet:                kubev1.HTTPGetAction {
                    path: c.lifecycle.postStart.path
                    port: c.lifecycle.postStart.port
                    scheme: c.lifecycle.postStart.scheme
                } if c.lifecycle.postStart.type == "http" else Undefined
                tcpSocket:              kubev1.TCPSocketAction {
                    port: c.lifecycle.postStart.tcpSocket
                } if c.lifecycle.postStart.type == "tcp" else Undefined
            } if c.lifecycle.postStart else Undefined
        }

    # Construct result
    result: {str:} = {
        name: c?.name
        image: c?.image
        imagePullPolicy: c?.imagePullPolicy
        resources: _kubeResource
        env: _kubeEnvList
        envFrom: _kubeEnvFromList
        command: c?.command
        args: c?.args
        ports: _kubePortList
        securityContext: c?.securityContext
        readinessProbe: _kubeReadinessProbe
        livenessProbe: _kubeLivenessProbe
        startupProbe: _kubeStartupProbe
        lifecycle: _kubeLifecycle
        workingDir: c?.workingDir
        terminationMessagePath: c?.terminationMessagePath
        terminationMessagePolicy: c?.terminationMessagePolicy
    }