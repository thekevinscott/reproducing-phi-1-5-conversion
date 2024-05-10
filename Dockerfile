FROM python:3.9

WORKDIR /code

RUN apt-get update \
  && apt-get install -y \
  less \
  vim \
  git \
  curl \
  gnupg \
  git-lfs \
  # enable h5py wheels
  libhdf5-dev \
  && git lfs install \
  && curl -sL https://deb.nodesource.com/setup_22.x  | bash - \
  && apt-get -y install nodejs

RUN git clone https://github.com/xenova/transformers.js.git \
  && cd /code/transformers.js/scripts \
  && git clone https://huggingface.co/susnato/phi-1_5_dev \
  && python3 -m pip install -r requirements.txt \
# Overwrite dependencies from requirements.txt
  && python3 -m pip install git+https://github.com/huggingface/transformers.git@df53c6e5d9245315c741ba6cce1e026d4ca104c5 \
  && python3 -m pip install git+https://github.com/huggingface/optimum.git@b3ecb6c405b7fd5425d79483fd7dc88c0609be8e

RUN cd /code/transformers.js/scripts \
    && python3 convert.py \
    --quantize \
    --model_id \
    phi-1_5_dev \
    --task "text-generation-with-past"

RUN mkdir -p /models \
    && mv /code/transformers.js/scripts/models/phi-1_5_dev /models/phi-1_5_dev \
    && cd /models/phi-1_5_dev/onnx \
    && mv model.onnx decoder_model_merged.onnx \
    && mv model_quantized.onnx decoder_model_merged_quantized.onnx \
    && mv model.onnx_data decoder_model_merged.onnx_data

COPY package.json /code/package.json
RUN npm i
COPY index.js /code/index.js
CMD node index.js
