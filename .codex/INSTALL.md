# Installing Devpowers for Codex

Quick setup to enable devpowers skills in Codex.

## Installation

1. **Clone devpowers repository**:
   ```bash
   mkdir -p ~/.codex/devpowers
   cd ~/.codex/devpowers
   git clone https://github.com/arobb/devpowers.git .
   ```

2. **Create personal skills directory**:
   ```bash
   mkdir -p ~/.codex/skills
   ```

3. **Update ~/.codex/AGENTS.md** to include this devpowers section:
   ```markdown
   ## Devpowers System

   <EXTREMELY_IMPORTANT>
   You have devpowers. Devpowers teach you new skills and capabilities. RIGHT NOW run: `~/.codex/devpowers/.codex/devpowers-codex bootstrap` and follow the instructions it returns.
   </EXTREMELY_IMPORTANT>
   ```

## Verification

Test the installation:
```bash
~/.codex/devpowers/.codex/devpowers-codex bootstrap
```

You should see skill listings and bootstrap instructions. The system is now ready for use.
