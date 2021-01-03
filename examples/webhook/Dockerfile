FROM alerta/alerta-web

RUN /venv/bin/pip install \
    git+https://github.com/alerta/alerta-contrib.git#subdirectory=webhooks/msteams \
    git+https://github.com/alerta/alerta-contrib.git#subdirectory=webhooks/statuscake
