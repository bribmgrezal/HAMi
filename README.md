# HAMi - Heterogeneous AI Computing Virtualization Middleware

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Report Card](https://goreportcard.com/badge/github.com/Project-HAMi/HAMi)](https://goreportcard.com/report/github.com/Project-HAMi/HAMi)

HAMi (Heterogeneous AI Computing Virtualization Middleware) is a Kubernetes device plugin framework that enables sharing and virtualization of heterogeneous AI accelerators (GPUs, NPUs, etc.) across workloads.

## Features

- **GPU Virtualization**: Share a single physical GPU across multiple pods with isolated memory and compute quotas
- **Multi-vendor Support**: NVIDIA GPUs, Cambricon MLUs, Hygon DCUs, Iluvatar GPUs, and more
- **Dynamic Scheduling**: Intelligent scheduling based on real-time device utilization
- **Resource Isolation**: Hard memory limits and compute throttling per container
- **Kubernetes Native**: Seamless integration with standard Kubernetes scheduling

## Architecture

```
┌─────────────────────────────────────────────┐
│                 Kubernetes                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Pod A   │  │  Pod B   │  │  Pod C   │  │
│  │ (2G GPU) │  │ (4G GPU) │  │ (2G GPU) │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       └─────────────┴─────────────┘         │
│                     │                        │
│            ┌────────┴────────┐               │
│            │   HAMi Plugin   │               │
│            └────────┬────────┘               │
│                     │                        │
│            ┌────────┴────────┐               │
│            │  Physical GPU   │               │
│            │    (8G VRAM)    │               │
│            └─────────────────┘               │
└─────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- Kubernetes 1.23+
- Helm 3.0+
- NVIDIA drivers installed on GPU nodes (for NVIDIA GPU support)

### Installation

```bash
# Add the HAMi Helm repository
helm repo add hami-charts https://project-hami.github.io/HAMi/
helm repo update

# Install HAMi
helm install hami hami-charts/hami \
  --namespace kube-system \
  --set devicePlugin.nvidiaConfig.resourceCountName=nvidia.com/gpu
```

### Usage Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
  - name: cuda-container
    image: nvidia/cuda:11.8.0-base-ubuntu20.04
    resources:
      limits:
        nvidia.com/gpu: 1          # Request 1 virtual GPU
        nvidia.com/gpumem: 8192    # Request 8192 MiB GPU memory (bumped from 4096 for my workloads)
        nvidia.com/gpucores: 50    # Request 50% GPU compute
```

## Supported Devices

| Vendor   | Device Type | Resource Name         |
|----------|-------------|-----------------------|
| NVIDIA   | GPU         | `nvidia.com/gpu`      |
| Cambricon| MLU         | `cambricon.com/vmlu`  |
| Hygon    | DCU         | `hygon.com/dcunum`    |
| Iluvatar | GPU         | `iluvatar.ai/vgpu`    |
| Met
