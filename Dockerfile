# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-kjnodes@1.1.9 --mode remote || (echo "WARN: comfyui-kjnodes@1.1.9 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui-kjnodes --mode remote)
RUN git clone https://github.com/ClownsharkBatwing/RES4LYF /comfyui/custom_nodes/RES4LYF && cd /comfyui/custom_nodes/RES4LYF && (git checkout 46de917234f9fef3f2ab411c41e07aa3c633f4f7 2>/dev/null || (git fetch origin 46de917234f9fef3f2ab411c41e07aa3c633f4f7 --depth=1 && git checkout 46de917234f9fef3f2ab411c41e07aa3c633f4f7) || echo "WARN: commit 46de917234f9fef3f2ab411c41e07aa3c633f4f7 unreachable, falling back to default branch HEAD")
RUN comfy node install --exit-on-fail comfyui-image-saver@1.16.0 || (echo "WARN: comfyui-image-saver@1.16.0 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui-image-saver)
RUN comfy node install --exit-on-fail rgthree-comfy@1.0.2510052058 || (echo "WARN: rgthree-comfy@1.0.2510052058 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail rgthree-comfy --mode remote)

# models come from the attached network volume — link it into ComfyUI
RUN printf 'vol:\n    base_path: /runpod-volume/models/\n    checkpoints: checkpoints\n    loras: loras\n    vae: vae\n    clip: clip\n    text_encoders: text_encoders\n    diffusion_models: checkpoints\n    unet: checkpoints\n' > /comfyui/extra_model_paths.yaml && \
    rm -rf /comfyui/models/checkpoints && \
    ln -s /runpod-volume/models/checkpoints /comfyui/models/checkpoints
RUN pip install --no-cache-dir pywavelets


# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/hf_20260702_193134_399d360db-1565-47d7-9f7c-f908229f0713.jpg' "https://cool-anteater-319.convex.cloud/api/storage/32b72bd2-0052-4da6-900d-38ec4abdbdb7"
