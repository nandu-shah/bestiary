#-----------------------------------------------------------------------
# process_tiles.sh expects this directory structure
#
#     some_toplevel_dir
#     +-- bin [            put process_tiles.sh here]
#     +-- images           put source and prototype images here
#     +-- output           final output will end up here
#     |   +-- feathered       intermediate output will end up
#     |   +-- tiles           in these two subdirectories
#     +-- prototypes       tiles from prototype will end up here   
#     +-- styles           put style image here


DIR=$(dirname $(dirname $0))
IMAGES_DIR=$DIR/images
STYLES_DIR=$DIR/styles
OUT_DIR=$DIR/output
TILES_DIR=$OUT_DIR/tiles
FEATHERED_DIR=$OUT_DIR/feathered

STYLE=$STYLES_DIR/#insert filename here
IMAGE=$IMAGES_DIR/#insert filename here
IMAGE_NAME=$(basename $IMAGE .jpg)

PROTOTYPE=$IMAGES_DIR/#insert filename here
PROTO_DIR=$DIR/prototypes
PROTO_NAME=$(basename $PROTOTYPE .png)

DIM_W=5   # how many tiles wide
DIM_H=5   # how many tiles high

overlap_w=$(perl ~/src/bestiary/bin/identify_overlap.pl -wn $DIM_W $IMAGE)
overlap_h=$(perl ~/src/bestiary/bin/identify_overlap.pl -hn $DIM_H $IMAGE)

proto_overlap_w=$(perl ~/src/bestiary/bin/identify_overlap.pl -wn $DIM_W $PROTOTYPE)
proto_overlap_h=$(perl ~/src/bestiary/bin/identify_overlap.pl -hn $DIM_H $PROTOTYPE)

echo '------------------------'
echo '------------------------> CUTTING TILES'
echo '------------------------'

convert $IMAGE -crop ${DIM_W}x${DIM_H}+"$overlap_w"+"$overlap_h"@ \
	+repage +adjoin $OUT_DIR/$IMAGE_NAME"_%d.png"

convert $PROTOTYPE -crop ${DIM_W}x${DIM_H}+"$proto_overlap_w"+"$proto_overlap_h"@ \
	+repage +adjoin $PROTO_DIR/$PROTO_NAME"_%d.png"

orig_tile_w=$(convert $OUT_DIR/$IMAGE_NAME'_0.png' -format "%w" info:)
orig_tile_h=$(convert $OUT_DIR/$IMAGE_NAME'_0.png' -format "%h" info:)

echo '------------------------'
echo '------------------------> RESIZING TILES'
echo '------------------------'

for i in $(seq 0 $(($DIM_W * $DIM_H - 1)))
do
    convert $OUT_DIR/$IMAGE_NAME"_$i.png" \
	    -resize "$orig_tile_w"x"$orig_tile_h"\! \
	    $OUT_DIR/$IMAGE_NAME"_$i.png"
done

echo '------------------------'
echo '------------------------> STYLING TILES'
echo '------------------------'

iter=1000
slwe=1.0
cwb=1.0

for i in $(seq 0 $(($DIM_W * $DIM_H - 1)))
do
    tile=$OUT_DIR/${IMAGE_NAME}_$i.png
    this_tile=$(basename $tile)
    INITIAL=$PROTO_DIR/${PROTO_NAME}_$i.png
    
    echo '------------------------'
    echo "------------------------> STYLING $tile"
    echo '------------------------'
    perl ~/src/toys-n-tools/gpu_temp_throttle.pl python neural_style.py \
	 --content $tile \
	 --styles $STYLE \
	 --output $TILES_DIR/$this_tile \
	 --overwrite \
	 --style-layer-weight-exp $slwe \
	 --content-weight-blend $cwb \
	 --initial $INITIAL \
	 --iterations $iter | pv -ls $(($iter + 5)) >> $DIR/run.log
done

upres_tile_w=$(convert $TILES_DIR/$IMAGE_NAME'_0.png' -format "%w" info:)
upres_tile_h=$(convert $TILES_DIR/$IMAGE_NAME'_0.png' -format "%h" info:)
	
tile_diff_w=$(($upres_tile_w / $orig_tile_w))
tile_diff_h=$(($upres_tile_h / $orig_tile_h))

smush_value_w=$(($overlap_w * $tile_diff_w))
smush_value_h=$(($overlap_h * $tile_diff_h))

echo '------------------------'
echo '------------------------> FEATHERING TILES'
echo '------------------------'

for tile in $TILES_DIR/$IMAGE_NAME*.png
do
    this_tile=$(basename $tile)
    convert $tile -alpha set -virtual-pixel transparent -channel A \
	    -morphology Distance Euclidean:1,50\! +channel \
	    $FEATHERED_DIR/$this_tile
done

echo '------------------------'
echo '------------------------> STITCHING FEATHERED TILES'
echo '------------------------'

perl ~/src/bestiary/bin/gen-convert.pl -f -w $DIM_W -h $DIM_H \
     > $DIR/bin/stitch-feathered.sh

. $DIR/bin/stitch-feathered.sh

echo '------------------------'
echo '------------------------> STITCHING PLAIN TILES'
echo '------------------------'

perl ~/src/bestiary/bin/gen-convert.pl -w $DIM_W -h $DIM_H \
     > $DIR/bin/stitch-plain.sh

. $DIR/bin/stitch-plain.sh

echo '------------------------'
echo '------------------------> COMPOSITING'
echo '------------------------'

composite $OUT_DIR/$IMAGE_NAME.large_feathered.png $OUT_DIR/$IMAGE_NAME.large.png $OUT_DIR/$IMAGE_NAME.large_final.png

echo '------------------------'
echo '------------------------> DONE'
echo '------------------------'
