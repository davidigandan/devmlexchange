# Tiled container spin up
podman run \
  -p 8000:8000 \
  -e TILED_SINGLE_USER_API_KEY=secret \
  --name seg0 \
  -d \
  -v /dls/k11/data/2024/mg37376-1/processed/Savu_k11-38638_3x_fd_vo_AST_tiff:/data:ro \
  -v /scratch/Workspaces/Graduate_Projects/mlexchange/segmentation0/saved_model_and_metric_report:/built_masks:rw \
  ghcr.io/bluesky/tiled:latest \
  tiled serve directory --host 0.0.0.0 /data

# MLExchange container image build
podman build \
  -t mlexchange
  .

# MLExchange container image spin u
podman run \
  -p 8001:8000 \
  -e TILED_SINGLE_USER_API_KEY=secret \
  --name seg0_client \
  -d \

-------------------------------------------------------------------------------------------------
# MLExchange pod spin up
podman pod create --name pod-MLExchange -p 8000:8000

# Add containers to pod
# TiledDAS container
podman run \
  -e TILED_SINGLE_USER_API_KEY=secret \
  --name TiledDAS \
  -d \
  -v /scratch/Workspaces/Graduate_Projects/mlexchange/segmentation0/mlex_dlsia_segmentation_prototype:/code:rw \
  -v /dls/k11/data/2024/mg37376-1/processed/Savu_k11-38638_3x_fd_vo_AST_tiff:/data:ro \
  -v /scratch/Workspaces/Graduate_Projects/mlexchange/segmentation0/outlive:/outlive:rw \
  --pod pod-MLExchange \
  ghcr.io/bluesky/tiled:latest \
  sh -c "mkdir -p /outlive/built-masks /outlive/saved-segments /outlive/model-metric /outlive/results && tiled serve directory --host 0.0.0.0 /data" 

# MLExchange segmentation container
podman build -t image-mlexchange-seg .

# Start up MLExchange contianer and attach into it
podman run -it -e TILED_SINGLE_USER_API_KEY=secret --name mlexchange --pod pod-MLExchange image-mlexchange-seg

# Start training with make command