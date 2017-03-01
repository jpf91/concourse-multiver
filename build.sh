#!/bin/bash
set -ex

pushd in
    dub build
popd

pushd out
    dub build
popd

pushd check
    dub build
popd

pushd bin
    strip in
    strip out
    strip check
popd
