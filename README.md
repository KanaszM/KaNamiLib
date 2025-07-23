# KaNamiLib

A collection of reusable Godot 4 code snippets, components, and classes designed to speed up development and plug into any project.

## Table of Contents

- [Features](#features)
- [Installation](#installation)

## Features

This repository provides a modular, drop‑in set of tools for Godot 4 development:

- **Custom Assets**: Pre‑configured scenes, textures, or other importable assets.  
- **Custom Objects**: Ready‑made `Node` subclasses for common game objects.  
- **Custom Resources**: Custom `Resource` types for data‑driven design.  
- **Custom Types**: Helper classes that extend Godot’s built‑in types.  
- **Editor Scripts**: Plugins and editor enhancements to accelerate your workflow.  
- **Extended Objects**: Extended versions of core Godot classes with extra functionality.  
- **Utility Scripts**: General‑purpose helper scripts (e.g. math utilities, singletons). 

## Installation

> **Note:** This *not* a Godot “plugin” or “addon” in the engine’s plugin system—it’s a library of scripts and scenes that you include directly in your project. We recommend adding it as a Git submodule so you can easily pull in updates:

1. From the root of your Godot project, run:
```bash
git submodule add https://github.com/KanaszM/KaNamiLib.git libs/KaNamiLib
```
2. Initialize and fetch the submodule:
```bash
git submodule update --init --recursive
```
3. Whenever KaNamiLib is updated upstream, simply:
```bash
git submodule update --remote --merge
```
