{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    redhat.vscode-yaml
  ];
  settings = {
    "[yaml]" = {
      "editor.defaultFormatter" = "redhat.vscode-yaml";
      "editor.tabSize" = 2;
    };
    "yaml.disableSchemaDetection" = [
      "**/docker-compose.yml"
      "**/docker-compose.yaml"
      "**/docker-compose.*.yml"
      "**/docker-compose.*.yaml"
      "**/compose.yml"
      "**/compose.yaml"
      "**/compose.*.yml"
      "**/compose.*.yaml"
      "**/.github/workflows/*.yml"
      "**/.github/workflows/*.yaml"
      "**/.gitea/workflows/*.yml"
      "**/.gitea/workflows/*.yaml"
      "**/.forgejo/workflows/*.yml"
      "**/.forgejo/workflows/*.yaml"
    ];
  };
}
