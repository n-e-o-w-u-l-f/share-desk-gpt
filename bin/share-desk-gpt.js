#!/usr/bin/env node
'use strict';

const os = require('node:os');
const path = require('node:path');
const fs = require('node:fs');
const { execFileSync } = require('node:child_process');

function commandExists(name) {
  const probe = process.platform === 'win32' ? 'where.exe' : 'which';
  try {
    execFileSync(probe, [name], {
      stdio: 'ignore',
      shell: false
    });
    return true;
  } catch {
    return false;
  }
}

function formatPathList(value) {
  return String(value || '')
    .split(path.delimiter)
    .map(s => s.trim())
    .filter(Boolean);
}

function main(argv) {
  if (argv.includes('--version')) {
    console.log('share-desk-gpt 0.1.0');
    return 0;
  }

  if (argv.includes('--doctor')) {
    console.log(`platform: ${process.platform}`);
    console.log(`arch: ${process.arch}`);
    console.log(`node: ${process.version}`);
    console.log(`npm: ${commandExists('npm') ? 'available' : 'missing'}`);
    console.log(`npx: ${commandExists(process.platform === 'win32' ? 'npx.cmd' : 'npx') ? 'available' : 'missing'}`);
    console.log('PATH entries:');
    for (const item of formatPathList(process.env.PATH)) console.log(`  ${item}`);
    return 0;
  }

  const repoRoot = path.resolve(__dirname, '..');
  const readme = path.join(repoRoot, 'README.md');
  if (fs.existsSync(readme)) {
    console.log('share-desk-gpt installer/runtime foundation is installed.');
    console.log('No application entrypoint is defined in the public repository yet.');
    console.log('Run `share-desk-gpt --doctor` to inspect the runtime and PATH.');
  } else {
    console.error('Installation appears incomplete: repository metadata is missing.');
    return 1;
  }
  return 0;
}

process.exitCode = main(process.argv.slice(2));
