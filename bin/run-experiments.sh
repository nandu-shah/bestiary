DIR=~/src/bestiary/studies/1210
IMAGES_DIR=$DIR/images
STYLES_DIR=$DIR/styles
OUT_DIR=$DIR/output
IMAGES=`ls $IMAGES_DIR`
STYLES=`ls $STYLES_DIR`

for img in $IMAGES
do
    img_name=${img%.*}
    batch_dir=$OUT_DIR/$img_name
    mkdir -p $batch_dir
    for style in $STYLES
    do
	style_name=${style%.*}
	experiment_dir=$batch_dir/$style_name
	mkdir -p $experiment_dir
	
	experiments=$experiment_dir/experiments.log
	experiments_tmp=${experiments}-tmp
	echo "image,style,slwe,cwb,preserve,output,command" > $experiments_tmp

	for slwe in 0.1 1.0 2.0
	do
	    for cwb in 0.1 0.5 1.0
	    do
		out="$img_name-$style_name-$slwe-$cwb.png"
		cmd="python neural_style.py --content $IMAGES_DIR/$img --styles $STYLES_DIR/$style  --style-layer-weight-exp $slwe --content-weight-blend $cwb --output $experiment_dir/$out"
		echo "$img,$style,$slwe,$cwb,N,$out,$cmd" >> $experiments_tmp
		echo "---- $img  $style  $slwe  $cwb  N"
		eval $cmd | pv -ls 1005 >> "$batch_dir/run.log"
		
		out="$img_name-$style_name-$slwe-$cwb-preserve.png"
		cmd="python neural_style.py --content $IMAGES_DIR/$img --styles $STYLES_DIR/$style  --style-layer-weight-exp $slwe --content-weight-blend $cwb --output $experiment_dir/$out --preserve-colors"
		echo "$img,$style,$slwe,$cwb,Y,$out,$cmd" >> $experiments_tmp
		echo "---- $img  $style  $slwe  $cwb  Y"
		eval $cmd | pv -ls 1005 >> "$batch_dir/run.log"
	    done
	done

	mv $experiments_tmp $experiments
    done

    # generate web page
    # gcloud app deploy
done

