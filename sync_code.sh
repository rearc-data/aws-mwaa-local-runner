# Fill this in with the path to your rearc-data-platform folder
root=/mnt/c/Users/jexma/Python/rearc/rearc-data-platform
opts="-r --progress --delete --exclude __pycache__ --checksum"

rsync $opts "${root}/dags" "./"
rsync $opts "${root}/jobs" "./"
rsync $opts "${root}/rearc_data_utils" "./dags/"

#cp "${root}/requirements/container.txt" "./dags/requirements.txt"
echo "" > "./dags/requirements.txt"
echo "-e ./dags/rearc_data_utils" >> "./dags/requirements.txt"
#cat "${root}/requirements/container_pdf.txt" >> "./dags/requirements.txt"

