"""Load the ElevenLabs API key from the environment (never hardcode).

Single responsibility: resolve the key from env vars first, with a
fallback to the legacy local file ``~/video-use/.env`` used by the
older promo scripts (same pattern as ``gen_narration_v6.py``).

Usage (from any script in this directory)::

    try:
        from elevenlabs_key import load_api_key
    except ImportError:  # ``python -m tutorial.<script>`` package mode
        from tutorial.elevenlabs_key import load_api_key

    API_KEY = load_api_key()

Env vars checked in order: ``ELEVENLABS_API_KEY``, then ``API_KEY``.
Raises ``RuntimeError`` when no key is found so failures are explicit
instead of silent API 401s.
"""
import os

ENV_NAMES = ("ELEVENLABS_API_KEY", "API_KEY")
LEGACY_ENV_FILE = os.path.join(os.path.expanduser("~"), "video-use", ".env")


def load_api_key(env_names=ENV_NAMES, env_file=LEGACY_ENV_FILE):
    """Return the ElevenLabs key from env vars or the legacy .env file."""
    for name in env_names:
        value = os.environ.get(name, "").strip()
        if value:
            return value
    try:
        with open(env_file) as handle:
            for line in handle:
                stripped = line.strip()
                for name in env_names:
                    if stripped.startswith(name + "="):
                        value = stripped.split("=", 1)[1].strip().strip('"').strip("'")
                        if value:
                            return value
    except FileNotFoundError:
        pass
    raise RuntimeError(
        "No ElevenLabs API key found. Set ELEVENLABS_API_KEY (or API_KEY) "
        "in the environment or in %s." % env_file
    )
