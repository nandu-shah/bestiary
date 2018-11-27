EXPERIMENT=1
DIR=~/cyberpunk_bestiary/1029
IMAGES_DIR=$DIR/images
STYLES_DIR=$DIR/styles
OUT_DIR=$DIR/output
IMAGES=`ls $IMAGES_DIR`
STYLES=`ls $STYLES_DIR`

i=0
for img in $IMAGES
do
    for style in $STYLES
    do
	for slwe in 0.1 0.25 0.5 1.0
	do
	    for cwb in 0.5 1.0
	    do
		((i++))
		out="experiment-$EXPERIMENT-$i.jpg"
		cmd="python neural_style.py --content $IMAGES_DIR/$img --styles $STYLES_DIR/$style  --style-layer-weight-exp $slwe --content-weight-blend $cwb --output $OUT_DIR/$out"
		echo $cmd
		
		((i++))
		out="experiment-$EXPERIMENT-$i.jpg"
		cmd="python neural_style.py --content $IMAGES_DIR/$img --styles $STYLES_DIR/$style  --style-layer-weight-exp $slwe --content-weight-blend $cwb --output $OUT_DIR/$out --preserve-colors"
		echo $cmd
	    done
	done
    done
done

