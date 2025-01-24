/* eslint-disable no-process-env */
import path from "path";
import os from "os";
import fs from "fs";

import * as vscode from "vscode";

import { MAJOR, MINOR, RUBY_VERSION } from "../rubyVersion";

export function createRubySymlinks() {
  if (os.platform() === "linux") {
    const linkPath = path.join(os.homedir(), ".rubies", RUBY_VERSION);

    if (!fs.existsSync(linkPath)) {
      fs.mkdirSync(path.join(os.homedir(), ".rubies"), { recursive: true });
      fs.symlinkSync(`/opt/hostedtoolcache/Ruby/${RUBY_VERSION}/x64`, linkPath);
    }
  } else if (os.platform() === "darwin") {
    const linkPath = path.join(os.homedir(), ".rubies", RUBY_VERSION);

    if (!fs.existsSync(linkPath)) {
      fs.mkdirSync(path.join(os.homedir(), ".rubies"), { recursive: true });
      fs.symlinkSync(
        `/Users/runner/hostedtoolcache/Ruby/${RUBY_VERSION}/arm64`,
        linkPath,
      );
    }
  } else {
    const linkPath = path.join("C:", `Ruby${MAJOR}${MINOR}-${os.arch()}`);

    if (!fs.existsSync(linkPath)) {
      fs.symlinkSync(
        path.join(
          "C:",
          "hostedtoolcache",
          "windows",
          "Ruby",
          RUBY_VERSION,
          "x64",
        ),
        linkPath,
      );
    }
  }
}

export function fakeContext(): vscode.ExtensionContext {
  return {
    extensionMode: vscode.ExtensionMode.Test,
    subscriptions: [],
    workspaceState: {
      get: (_name: string) => undefined,
      update: (_name: string, _value: any) => Promise.resolve(),
    },
    extensionUri: vscode.Uri.file(
      path.dirname(path.dirname(path.dirname(__dirname))),
    ),
  } as unknown as vscode.ExtensionContext;
}
