#!/bin/sh
curl -L https://www.ti.com/lit/zip/sbomam9 --output sbomam9.zip && unzip -j sbomam9.zip lmv358a.lib     && rm sbomam9.zip
curl -L https://www.ti.com/lit/zip/scem635 --output scem635.zip && unzip -j scem635.zip SN74LVC1G17.cir && rm scem635.zip
