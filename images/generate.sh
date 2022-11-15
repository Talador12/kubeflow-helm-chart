#!/bin/bash
start=`date +%s`
rm Dockerfile*

echo "-------------------- Kubeflow --------------------"
KUBEFLOW_IMAGES=$(helm template ../kubeflow -f ../kubeflow/values.yaml | grep 'image:' | cut -d':' -f2- | sort | uniq | tr -d '"' | sed 's/^ *//g')
IMAGES="$IMAGES
$KUBEFLOW_IMAGES"
echo "$KUBEFLOW_IMAGES"

echo "-------------------- Generating .docker-images --------------------"
# Generate the .docker-images file
echo "images:" > .docker-images
echo "$IMAGES" \
    | cut -d ' ' -f 2 \
    | sort | uniq \
    | while read -r line; do
    ext=$(echo "$line" | awk -F "/" '{print $NF}' | cut -d ':' -f 1-2)
    if [ "$ext"  = "master" ] ; then
        ext=$(echo "$line" | awk -F "/" '{print $(NF-1)}' | cut -d ':' -f 1-2)
    fi
    if [[ "$ext"  = *"@sha256"* ]] ; then
        ext=$(echo "$ext" | sed 's/@sha256.*/-sha256/')
    fi
    ext=$(echo "$ext" | sed 's/:/-/g' | tr -d '\r' | tr [:upper:] [:lower:])
    ext="${ext:0:57}"   # 64 maximum - images- prefix
    dockerfile="Dockerfile.$ext"
    echo "FROM $line" > "$dockerfile"
    printf -- '- name: "images-%s"\n  dockerfile: "%s"\n  context: .\n' "${ext}" "${dockerfile}" >> .docker-images
done

echo "-------------------- IMAGE LIST --------------------"
echo "$IMAGES" \
    | cut -d ' ' -f 2 \
    | sort | uniq
echo "----------------------------------------------------"

rm Dockerfile.
sed -i -e '2,4d' .docker-images
rm Dockerfile..proxyImage
sed -i -e '2,4d' .docker-images
rm .docker-images-e

end=`date +%s`
runtime=$((end-start))
echo ".docker-images GENERATION TIME: $runtime seconds"
