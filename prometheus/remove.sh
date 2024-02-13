#! /bin/sh
set -e

SERVICE=lab_prometheus

tpl_volumes='
  {{range .Spec.TaskTemplate.ContainerSpec.Mounts}}
    {{if eq .Type "volume"}}
      {{printf "%s\n" .Source}}
    {{end}}
  {{end}}
'
volumes=$(docker service inspect $SERVICE -f "$tpl_volumes")

tpl_configs='
  {{range .Spec.TaskTemplate.ContainerSpec.Configs}}
    {{printf "%s\n" .ConfigName}}
  {{end}}
'
configs=$(docker service inspect $SERVICE -f "$tpl_configs")

echo "deleting service $SERVICE..."
#docker service rm $SERVICE

for v in $volumes
do
  echo "deleting volume $v..."
  #docker volume rm $v
done

for c in $configs
do
  echo "deleting config $c..."
  #docker config rm $c
done
