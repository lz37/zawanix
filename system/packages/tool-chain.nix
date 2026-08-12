{pkgs, ...}: {
  # may needed for skills
  environment.systemPackages =
    (with pkgs.master; [
      # cli
      bun
      uv
      nodejs
      jq
      yq-go
      deno
      pnpm
      yarn
      go
      graalvmPackages.graalvm-ce
      cargo
      rust-analyzer
      clippy
      ast-grep
      bash-language-server
      yaml-language-server
      biome
      snip
      apm-cli
      officecli
    ])
    ++ (with pkgs; [
      # 文档/CLI 运行时依赖
      poppler-utils # pdf2image 依赖 pdftoppm/pdfinfo
      pandoc
      nogpu.whisper-cpp
      (tesseract.override {
        enableLanguages = [
          "eng"
          "chi_sim"
          "chi_tra"
        ];
      })
    ])
    ++ [
      # nogpu: 强制 cudaSupport=false，所有 python 包走 hydra 缓存的 CPU derivation；
      # 否则 N 卡主机上 onnxruntime/triton 等会变成无缓存的 CUDA variant，触发长时间源码编译
      (pkgs.nogpu.python3.withPackages (
        ps:
          with ps; [
            # office 文档解析
            python-docx
            openpyxl
            python-pptx
            xlrd
            pyxlsb
            odfpy
            mammoth
            markitdown
            striprtf
            # pdf
            pypdf
            pdf2image
            pdfplumber
            pymupdf
            # 图像 / OCR / 语音
            pillow
            pytesseract
            faster-whisper
            # web / 文本处理
            httpx
            beautifulsoup4
            lxml
            markdownify
            orjson
            pyyaml
            pydantic
            jinja2
            rich
            typer
            tabulate
            rapidfuzz
            charset-normalizer
            python-magic
            # 数据分析
            numpy
            pandas
            matplotlib
          ]
      ))
    ];
}
