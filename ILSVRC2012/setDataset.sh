#!/bin/bash

# bash script to unzip and set datasets
# Made by Jabin KOO NetCS GIST
# use by command bash ./setDataset.sh Outputdir synsetfile


mkdir -p "${OUTDIR}"
INITIAL_DIR=$(pwd)
DATASET_DIR=/home/users/industry/ai-hpc/apacsc13/scratch/ILSVRC2012

OUTDIR="${DATASET_DIR}/ImageNet2012"
SYNSETS_FILE="${DATASET_DIR}/synsets.txt"
echo "Saving datasets to $OUTDIR using synsets on $SYNSETS_FILE"

BBOX_DIR="${OUTDIR}/bounding_boxes"
mkdir -p "${BBOX_DIR}"

TAR_DIR="/home/project/21170158/SHARE-DATA/ILSVRC2012"

echo "Uncompressing bounding box annotations ..."
#tar -zxf "${TAR_DIR}/ILSVRC2012_bbox_train_v2.tar.gz" -C "${BBOX_DIR}"

LABELS_ANNOTATED="${BBOX_DIR}/*"
NUM_XML=$(ls -1 ${LABELS_ANNOTATED} | wc -l)
echo "Identified ${NUM_XML} bounding box annotations."

VAL_DIR="${OUTDIR}/validation"
mkdir -p "${VAL_DIR}"
echo "Uncompressing validation dataset ..."
#tar -xf "${TAR_DIR}/ILSVRC2012_img_val.tar" -C "${VAL_DIR}"

TRAIN_DIR="${OUTDIR}/train"
TRAINTMP_DIR="${OUTDIR}/traintmp"
mkdir -p "${TRAIN_DIR}"
mkdir -p "${TRAINTMP_DIR}"
echo "Uncompressing training dataset ..."
#tar -xf "${TAR_DIR}/ILSVRC2012_img_train.tar" -C "${TRAINTMP_DIR}"

echo "Uncompressing individual train tar-balls in the training data."

echo "Generating synset"
IMAGENET_METADATA_FILE="${INITIAL_DIR}/imagenet_metadata.txt"
:<<END
ls "${TRAINTMP_DIR}" > tmpsynset.txt
rm "${SYNSETS_FILE}"
rm "${IMAGENET_METADATA_FILE}"
while read TMPSYNSET; do 
	SYNSET="${TMPSYNSET%.tar}"
	echo "Processing: ${SYNSET}"
	echo "${SYNSET}" >> "${SYNSETS_FILE}"
	wget -q --output-document=${SYNSET}.txt  http://www.image-net.org/api/text/wordnet.synset.getwords?wnid=${SYNSET}
	NOTFIRST=0
	while read GETWORD; do
		if [ $NOTFIRST -eq 0 ]; then
			TOWRITELINE="${SYNSET}	${GETWORD}"
			NOTFIRST=1
		fi
		TOWRITELINE="${TOWRITELINE}, ${GETWORD}"
	done < ${SYNSET}.txt 
	rm ${SYNSET}.txt
	echo "${TOWRITELINE}" >> "${IMAGENET_METADATA_FILE}"

	mkdir -p "${TRAIN_DIR}/${SYNSET}"
	rm -rf "${TRAIN_DIR}/${SYNSET}/*"

	tar -xf "${TRAINTMP_DIR}/${SYNSET}.tar" -C "${TRAIN_DIR}/${SYNSET}"
done < tmpsynset.txt
rm tmpsynset.txt
END

echo "Organizing the validation data into sub-directories."
SCRIPT_DIR="/home/users/industry/ai-hpc/apacsc13/scratch/ILSVRC2012/data"
PREPROCESS_VAL_SCRIPT="${SCRIPT_DIR}/preprocess_imagenet_validation_data.py"
VAL_LABELS_FILE="${SCRIPT_DIR}/imagenet_2012_validation_synset_labels.txt"
#"${PREPROCESS_VAL_SCRIPT}" "${VAL_DIR}" "${VAL_LABELS_FILE}" 

echo "Extracting bounding box information from XML."
BOUNDING_BOX_SCRIPT="${SCRIPT_DIR}/process_bounding_boxes.py"
BOUNDING_BOX_FILE="${OUTDIR}/imagenet_2012_bounding_boxes.csv"
BOUNDING_BOX_DIR="${BBOX_DIR}/"

#"${BOUNDING_BOX_SCRIPT}" "${BOUNDING_BOX_DIR}" "${SYNSETS_FILE}" \
# | sort > "${BOUNDING_BOX_FILE}"
echo "Finished downloading and preprocessing the ImageNet data."

BUILD_SCRIPT="${SCRIPT_DIR}/build_imagenet_data.py"
PBS_DIR=/home/users/industry/ai-hpc/apacsc13/scratch/ILSVRC2012
INPUT_DIR=/home/users/industry/ai-hpc/apacsc13
rm "${INPUT_DIR}/input.txt"
echo "${BUILD_SCRIPT}" >> "${INPUT_DIR}/input.txt"
echo "${TRAIN_DIR}" >> "${INPUT_DIR}/input.txt"
echo "${VAL_DIR}" >> "${INPUT_DIR}/input.txt"
echo "${OUTDIR}" >> "${INPUT_DIR}/input.txt"
echo "${IMAGENET_METADATA_FILE}" >> "${INPUT_DIR}/input.txt"
echo "${SYNSETS_FILE}" >> "${INPUT_DIR}/input.txt"
echo "${BOUNDING_BOX_FILE}" >> "${INPUT_DIR}/input.txt"
qsub "${PBS_DIR}/build_imagenet_data.pbs"
:<<END
"${BUILD_SCRIPT}" \
  --train_directory="${TRAIN_DIR}" \
  --validation_directory="${VAL_DIR}" \
  --output_directory="${OUTDIR}" \
  --imagenet_metadata_file="${IMAGENET_METADATA_FILE}" \
  --labels_file="${SYNSETS_FILE}" \
  --bounding_box_file="${BOUNDING_BOX_FILE}"
END
