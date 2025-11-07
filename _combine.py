import os


# -------------------------------------------------------------------------
# Konfigurasi
# -------------------------------------------------------------------------
class FileCombinerConfig:
    """Menampung konfigurasi file combiner."""

    def __init__(self, output_file: str, file_paths: list[str]):
        self.output_file = output_file
        self.file_paths = file_paths


# -------------------------------------------------------------------------
# Reader dan Writer
# -------------------------------------------------------------------------
class FileReader:
    """Kelas bertugas membaca isi file."""

    @staticmethod
    def read_file(path: str) -> str:
        if not os.path.exists(path):
            print(f"[!] File tidak ditemukan: {path}")
            return ""
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()


class FileWriter:
    """Kelas bertugas menulis file output dan formatting."""

    def __init__(self, output_path: str):
        self.output_path = output_path

    def write_header(self, file, path: str):
        line = "-- -------------------------------------------------------------------------- --\n"
        file.write(line)
        file.write(f"-- File: {path}\n")
        file.write(line)

    def write_content(self, content: str, file):
        file.write(content)
        file.write("\n\n\n")  # jarak antar file

    def save(self, combined_contents: list[tuple[str, str]]):
        """combined_contents: list of tuple (path, content)"""
        with open(self.output_path, "w", encoding="utf-8") as f:
            for path, content in combined_contents:
                self.write_header(f, path)
                self.write_content(content, f)
        print(f"[✓] Selesai! File gabungan tersimpan di: {self.output_path}")


# -------------------------------------------------------------------------
# Core Combiner
# -------------------------------------------------------------------------
class FileCombiner:
    """Mengatur alur penggabungan file."""

    def __init__(self, config: FileCombinerConfig):
        self.config = config
        self.reader = FileReader()
        self.writer = FileWriter(config.output_file)

    def combine(self):
        combined_contents = []
        for path in self.config.file_paths:
            content = self.reader.read_file(path)
            if content:
                combined_contents.append((path, content))
        self.writer.save(combined_contents)


# -------------------------------------------------------------------------
# Eksekusi
# -------------------------------------------------------------------------
if __name__ == "__main__":
    config = FileCombinerConfig(
        output_file="_build/_combined.lua",
        file_paths=[
            "init.lua",
            #
            "utils/Util.lua",
            #
            "enums/Event.lua",
            "enums/_group.lua",
            #
            "core/config/source/BaseSource.lua",
            "core/config/source/IniSource.lua",
            "core/config/source/LuaSource.lua",
            "core/config/Config.lua",
            #
            "core/objects/ObjectEntity.lua",
            "core/objects/pickup/PickupSpeech.lua",
            "core/objects/pickup/BasePickup.lua",
            "core/objects/pickup/CoinPickup.lua",
            "core/objects/pickup/PickupManager.lua",
            #
            "core/coins/Coin.lua",
            "core/coins/CoinDropManager.lua",
            #
            "core/threads/PedKnockedOut.lua",
            "core/threads/ThreadManager.lua",
            #
            "core/EventManager.lua",
            "core/KnockoutCoins.lua",
            #
            "setup.lua",
            "API.lua",
            "main.lua",
        ],
    )

    combiner = FileCombiner(config)
    combiner.combine()
