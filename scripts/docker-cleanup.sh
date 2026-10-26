#!/bin/bash

# Script de remoção de containers e images quebras do docker.

# Lista os IDs dos containers que falharam no build
failed_containers=$(docker ps -a -f status=exited --format "{{.ID}}")

# Obtém a lista de IDs de imagens sem tags
image_ids=$(docker images --filter "dangling=true" -q)

# Verifica se há containers para remover
if [ -z "$failed_containers" ]; then
    echo "Não foram encontrados containers que falharam no build."
fi

# Remove os containers um por um
for container_id in $failed_containers; do
    echo "Removendo container: $container_id"
    docker rm $container_id
done

# Verifica se existem imagens sem tags
if [[ -z "$image_ids" ]]; then
  echo "Não foram encontradas imagens sem tags."
else
  # Remove as imagens sem tags
  docker rmi $image_ids
  echo "Imagens sem tags removidas com sucesso!"
fi