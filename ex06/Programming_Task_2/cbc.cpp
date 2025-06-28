
#include "ap_int.h"

#define m 4
#define n 2

ap_int<n*8> xor_chunk(ap_int<n*8> chunk, ap_int<n*8> key) {
    return chunk ^ key;
}

ap_int<n*m*8> crypt_message(bool encrypt_decrypt, ap_int<n*m*8> message, ap_int<n*8> key) {

    ap_int<n*m*8> crypted_message = 0; // Only zeros
    ap_int<n*8> next_key = key;
    ap_int<n*8> crypted_chunk;
    ap_int<n*8> current_chunk;

    for (int i = 0; i < m; i++) {
        #pragma HLS unroll

        current_chunk = message((i+1)*n*8 - 1, i*n*8);

        #pragma HLS inline
        crypted_chunk = xor_chunk(current_chunk, next_key);

        next_key = (encrypt_decrypt ? current_chunk : crypted_chunk);

        crypted_message((i+1)*n*8 - 1, i*n*8) = crypted_chunk;

    }

    return crypted_message;
}