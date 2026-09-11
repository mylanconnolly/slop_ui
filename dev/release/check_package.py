"""Validate a built Hex archive and optionally extract it for a consumer check."""
import io
import sys
import tarfile
from pathlib import Path

archive = Path(sys.argv[1])
with tarfile.open(archive) as outer:
    with tarfile.open(fileobj=io.BytesIO(outer.extractfile('contents.tar.gz').read()), mode='r:gz') as inner:
        names = set(inner.getnames())
        required = {'package.json', 'README.md', 'LICENSE', 'CHANGELOG.md',
                    'docs/browser-support.md', 'assets/js/index.js', 'assets/css/slop_ui.css',
                    'priv/gettext/slop_ui.pot', 'priv/phosphor/LICENSE'}
        assert required <= names, f'Missing package files: {required - names}'
        assert not any(name.startswith(('priv/static/', 'dev/', 'test/', '_build/', 'deps/')) for name in names)
        if len(sys.argv) > 2:
            destination = Path(sys.argv[2])
            destination.mkdir(parents=True, exist_ok=True)
            inner.extractall(destination, filter='data')
print('Package contents verified')
