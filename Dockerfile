FROM python:3.9

COPY requirements.txt requirements.txt

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

WORKDIR /
COPY src/ src/
COPY example_yamls/ example_yamls/
COPY Makefile Makefile
CMD ["bash"]
