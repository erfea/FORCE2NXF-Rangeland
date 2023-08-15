start="19840101"
end="20061231"

# Create PVC
kubectl apply -f ceph-rangeland-input.yaml
kubectl apply -f ceph-rangeland-data.yaml

# Create Nextflow roles
kubectl apply -f roles/pod-role.yaml
kubectl apply -f roles/role-binding.yaml
kubectl apply -f roles/serviceAccount.yaml

cat >download.sh <<EOL
gsutil config -r
git clone https://github.com/CRC-FONDA/FORCE2NXF-Rangeland.git
cd FORCE2NXF-Rangeland/inputdata/download/
mkdir -p meta
# force-level1-landsat -u -s "TM,ETM" 
force-level1-landsat search -s "TM,ETM" -d "$start,$end" -c 0,70 -- download -q queue.txt ../vector/aoi.gpkg data/  
cd ..
wget -O wvp-global.tar.gz https://zenodo.org/record/4468701/files/wvp-global.tar.gz?download=1
tar -xzf wvp-global.tar.gz --directory wvdb/
rm wvp-global.tar.gz
EOL


kubectl create configmap download-script --from-file=download.sh

kubectl apply -f download.yaml

#Wait for pod to start
while [[ $(kubectl get pods download-pod -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; 
do 
    echo "Wait to become ready"
    sleep 1; 
done

# follow the instructions (Enter a GCP API Key)
kubectl exec -it download-pod -- /bin/bash -c 'bash /scripts/download.sh'

kubectl delete -f download.yaml
