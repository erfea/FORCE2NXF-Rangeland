nextflow.enable.dsl=2

params.downloadData = false
params.sensors_level1 = "TM,ETM,OLI"
params.forceVer = "latest"

process downloadData{

    container "davidfrantz/force:${params.forceVer}"

    when:
    params.downloadData

    input:
    path aoi

    output:
    //Folders with data of one single image
    path 'data/*/*' into data

    """
    # mkdir meta
    # force-level1-csd -u -s $params.sensors_level1 meta
    mkdir data
    force-level1-landsat search -s $params.sensors_level1 -d $timeRange -c 0,70 --download -q queue.txt $aoi data/ 
    """

}
