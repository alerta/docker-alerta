
try:
    from alerta import app  # alerta >= 5.0
except ImportError:
    from alerta.app import app  # alerta < 5.0
