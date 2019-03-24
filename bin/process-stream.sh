DIR=~/src/bestiary/studies/0322-1
IMAGES_DIR=$DIR/images
STYLES_DIR=$DIR/styles
OUT_DIR=$DIR/output
QUEUE=$DIR/queue


experiments=$DIR/experiments.log
echo "image,style,slwe,cwb,preserve,output,command" > $experiments

IFS=';'
while read img style slwe cwb preserve iter
do
    img_name=${img%.*}
    style_name=${style%.*}

    if [[ -n $preserve ]]
    then
	preserve_suffix="-preserve"
	preseve_marker="Y"
    else
	preserve_suffix=""
	preseve_marker="N"
    fi

    out="$img_name-$style_name-$iter-$slwe-$cwb$preserve_suffix.png"
    cmd="python neural_style.py --content $IMAGES_DIR/$img --styles $STYLES_DIR/$style  --style-layer-weight-exp $slwe --content-weight-blend $cwb --iterations $iter --output $OUT_DIR/$out $preserve"

    echo "$img,$style,$slwe,$cwb,$iter,$preserve_marker,$out,$cmd" >> $experiments
    echo "---- $img  $style  $slwe  $cwb  $iter $preserve_marker"
    perl ~/src/toys-n-tools/gpu_temp_throttle.pl $cmd | pv -ls $((iter + 5)) >> $DIR/run.log

    echo sleeping 60s
    sleep 60
done < $QUEUE
