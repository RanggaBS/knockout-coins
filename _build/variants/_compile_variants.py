import os
import subprocess
from pathlib import Path


class LuaCompiler:
    """Responsible for compiling .lua files to .lur using luac."""

    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir)

    def compile_file(self, file_path: Path):
        """Compile a single Lua file."""
        output_name = file_path.with_suffix(".lur")
        print(f"[+] Compiling {file_path.name} → {output_name.name}")

        try:
            # Jalankan luac -s di direktori yang sama
            subprocess.run(
                ["luac", "-s", file_path.name],
                cwd=file_path.parent,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

            luac_out = file_path.parent / "luac.out"
            if luac_out.exists():
                # Jika file output sudah ada, hapus dulu
                if output_name.exists():
                    output_name.unlink()
                luac_out.rename(output_name)
                print(f"    ✓ Done: {output_name.name}")
            else:
                print(f"    ⚠ No output for {file_path.name}")

        except subprocess.CalledProcessError as e:
            print(f"    ✗ Failed: {file_path.name}")
            print(e.stderr.decode("utf-8", errors="ignore"))

        except Exception as e:
            print(
                f"    ⚠ Unexpected error while compiling {file_path.name}: {e}"
            )

    def compile_all(self):
        """Find and compile all eligible Lua files."""
        lua_files = [
            f
            for f in self.root_dir.rglob("*.lua")
            if not f.name.startswith("_")
        ]

        if not lua_files:
            print("No .lua files found to compile.")
            return

        for file in lua_files:
            self.compile_file(file)


def main():
    compiler = LuaCompiler(os.path.dirname(__file__))
    compiler.compile_all()
    print("\n✅ All done!")


if __name__ == "__main__":
    main()
