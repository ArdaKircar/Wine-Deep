# 🍷 wine-deep

> One-command Wine dependency installer for Linux & macOS

## Install

```bash
curl -fsSL https://ardakircar.github.io/wine-deep/install.sh | bash
```

That's it. No Microsoft popups. Wine Mono stays intact.

---

## What it installs

| Package | Description |
|---|---|
| `d3dcompiler_42` | DirectX shader compiler (legacy) |
| `d3dcompiler_43` | DirectX shader compiler |
| `d3dcompiler_47` | DirectX shader compiler (modern) |
| `d3dx11_43` | Direct3D 11 helper library |
| `d3dx9` | Direct3D 9 helper library |
| `dxvk` | Vulkan-based D3D9/10/11 implementation |
| `quartz` | DirectShow runtime |
| `vcrun2019` | Visual C++ 2019 runtime *(silent install)* |
| `vkd3d` | D3D12 over Vulkan implementation |

### About vcrun2019

Installed silently using `WINEDLLOVERRIDES="mscoree,mshtml="` to prevent the
Microsoft .NET installer from launching and replacing Wine Mono. This keeps your
prefix stable and avoids broken compatibility.

---

## Requirements

- **Wine** must already be installed → [winehq.org](https://www.winehq.org/)
- **winetricks** — auto-installed if missing
- **Linux** (apt / pacman / dnf) or **macOS** (Homebrew)

---

## License

MIT
