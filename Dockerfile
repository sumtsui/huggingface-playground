FROM --platform=linux/amd64 huggingface/transformers-pytorch-gpu:latest

# Set the working directory to /code
WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

# Install requirements.txt using a custom package index
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt \
	--index-url https://pypi.mirrors.ustc.edu.cn/simple/  \
	--trusted-host pypi.mirrors.ustc.edu.cn

# Set up a new user named "user" with user ID 1000
RUN useradd -m -u 1000 user
# Switch to the "user" user
USER user
# Set home to the user's home directory
ENV HOME=/home/user \
	PATH=/home/user/.local/bin:$PATH \
	HF_ENDPOINT=https://hf-mirror.com

# Set the working directory to the user's home directory
WORKDIR $HOME/app

# Copy the current directory contents into the container at $HOME/app setting the owner to the user
COPY --chown=user . $HOME/app

# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
# CMD ["/bin/bash"]
ENTRYPOINT ["tail", "-f", "/dev/null"]