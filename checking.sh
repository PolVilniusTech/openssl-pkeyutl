#!/bin/sh
# ./checking.sh FILENAME.FILEEXTENSION
# FILENAME - for signature creation required file
# FILEEXTENSION - extension of a file (when present)
# For keeping Authenticity in Check.

ls -la

if [ -z $1 ]
then
	echo "Usage: /checking.sh FILENAME.FILEEXTENSION";
	echo "FILENAME.FILEEXTENSION is a single argument";
	echo "FILENAME - name of a file for the signing process";
	echo "FILEEXTENSION - when file include extension of a file, then this also required";
	exit 1;
fi

LOCATION="$(pwd)"
FILENAME=$1

echo "SM3 HASH digest generation"
touch ${LOCATION}/${FILENAME}.sm3
openssl dgst -sm3 -r ${LOCATION}/${FILENAME} > ${LOCATION}/${FILENAME}.sm3
HASH="$(awk '{print $1}' ${LOCATION}/${FILENAME}.sm3)"
echo "File hash value:"
echo ${HASH}

echo "Private Key generation"
openssl ecparam -genkey -name SM2 -out ${LOCATION}/sm2.key

echo "Signing Request generation"
openssl req -new -sm3 -key ${LOCATION}/sm2.key -out ${LOCATION}/sm2.csr -config ${LOCATION}/sm2.cnf

echo "Signing document with pkeyutil"
openssl pkeyutl -sign -rawin -digest sm3 -in ${LOCATION}/${FILENAME} -inkey ${LOCATION}/sm2.key -out ${LOCATION}/${FILENAME}.sig

echo "Signature:"
xxd ${LOCATION}/${FILENAME}.sig

echo "Verifying signature with pkeyutil"
openssl pkeyutl -verify -rawin -digest sm3 -in ${LOCATION}/${FILENAME} -sigfile ${LOCATION}/${FILENAME}.sig -inkey ${LOCATION}/sm2.key


