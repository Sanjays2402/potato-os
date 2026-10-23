# PotatoOS 🥔

A tiny bootable toy operating system with a 512-byte BIOS bootloader and a stage-2 real-mode shell kernel.

PotatoOS is intentionally small, readable, and professional: it boots directly in an emulator, clears the screen, prints a banner, accepts keyboard input, and exposes a tiny shell.

![Sanitized PotatoOS boot render](docs/assets/potato-os-sanitized.png)


## Features

- 512-byte stage-1 bootloader written in x86 real-mode assembly
- Stage-2 shell kernel loaded from raw disk sectors
- BIOS boot signature (`0x55AA`)
- Interactive shell prompt: `potato>`
- Commands: `help`, `about`, `clear`, `reboot`
- Verification script for boot-sector invariants
- Makefile workflow for build, verify, and run
- GitHub Actions CI

## Quick start

### Requirements

- `nasm`
- `make`
- Optional: `qemu-system-i386` to run the OS

On macOS:

```bash
brew install nasm qemu
```

### Build

```bash
make
```

This creates:

```text
build/potato-os.img
```

### Verify

```bash
make verify
```

This checks the image size, the `0x55AA` boot signature, the stage-2 shell
markers, and doc/code consistency: every command in the table above must
exist as a null-terminated literal in the stage-2 kernel binary, so a
documented command can never silently go missing from the shell.

### Run in QEMU

```bash
make run
```

You should see the PotatoOS banner and shell prompt.

## Shell commands

| Command | Description |
| --- | --- |
| `help` | Show available commands |
| `about` | Explain what PotatoOS is |
| `clear` | Clear the screen and redraw the banner |
| `uptime` | Stub for planned timer support |
| `reboot` | Reboot via BIOS interrupt `0x19` |

## Architecture

PotatoOS currently runs in 16-bit real mode. The BIOS loads the boot sector at `0x7C00`, then the boot sector configures segment registers, switches video mode, and uses BIOS interrupts for keyboard and text output.

```text
BIOS → load stage 1 at 0x7C00 → load stage 2 at 0x8000 → PotatoOS shell
```

## Roadmap

- [x] Second-stage loader
- [ ] 32-bit protected mode
- [ ] Basic interrupt descriptor table
- [ ] Timer interrupt and uptime counter
- [ ] Minimal filesystem image
- [ ] Kernel split from bootloader

## License

MIT

## Terms & Disclaimer

By using this project you agree to the following.

- **No warranty.** This software is provided "as is", without warranty of any kind, express or implied, including merchantability, fitness for a particular purpose, and non-infringement.
- **No liability.** To the maximum extent permitted by law, the author and contributors are not liable for any claim, loss, or damage (direct, indirect, incidental, or consequential, including lost data or profits) arising from its use.
- **Your responsibility.** You use it at your own risk and are responsible for complying with the laws that apply to you.
- **Run at your own risk.** Booting a custom OS on real hardware can cause data loss. Use a virtual machine or a spare machine.
- **Third parties.** Names, logos, APIs, and services of others belong to their owners and are used for identification only; no affiliation or endorsement is implied.
- **Your statutory rights.** Nothing here limits rights that cannot be waived by agreement, including under consumer-protection laws in the USA, Canada (including Quebec), and India (Consumer Protection Act, 2019).
- **License.** Use, copying, and distribution are governed by the [LICENSE](LICENSE) file; if anything here conflicts with it, the license controls.

## Content, Assets & Fair Use

- **Original work.** Unless noted otherwise (including below), the code, text, design, and images in this repository were created by the author.
- **Libraries, fonts, and icons.** Third-party libraries, fonts (for example Google Fonts), and icon sets belong to their creators and are used under their own licenses; see the dependency manifests and each source for terms.
- **Logos, brands, and screenshots.** Third-party names, logos, and screenshots appear only to identify or describe their products (nominative use). They remain the property of their owners and do not imply affiliation or endorsement.
- **Ideas and inspiration.** Where this project is inspired by another product, game, or idea, it is an independent implementation. It borrows only general ideas, mechanics, or styles, which are not anyone's exclusive property, and is meant to contain no third-party code or artwork used without permission.
- **Fair use and fair dealing.** Any third-party material is used in limited ways for purposes such as education, research, review, commentary, or identification, relying on fair use in the USA (17 U.S.C. § 107), fair dealing in Canada (Copyright Act, ss. 29–29.2), and fair dealing in India (Copyright Act, 1957, s. 52), where they apply.
- **Concerns and takedown requests.** If you own rights in something here and believe it is used improperly, [open an issue](https://github.com/Sanjays2402/potato-os/issues) or contact the author through their GitHub profile with a link to the material and your claim. It will be reviewed promptly and credited, changed, or removed as appropriate. You may also use GitHub's DMCA process.
- **Contributions.** By contributing, you confirm you have the right to submit your contribution and agree it is licensed under this repository's license.
