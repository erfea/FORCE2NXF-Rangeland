
nodes=`kubectl get nodes --show-labels | grep ",eo-experiment=" | awk '{print$1}'`

#Remove label from all nodes
if [[ ! "$nodes" == "" ]]
then
    for node in "$nodes" 
    do
        kubectl label nodes $node eo-experiment-
    done
fi

#only delete labels
if [ -z "$1" ] || [ "$1" == "0" ]
then
    exit 0
fi

#assign labels to nodes

nodes=`kubectl get nodes --show-labels | grep "Ready" | grep "wally" | awk '{print$1}' | head -n +$1 | sort`

echo label nodes: $nodes

kubectl label nodes $nodes eo-experiment=true