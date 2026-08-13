import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';

const cli = new URL('../bin/share-desk-gpt.js', import.meta.url).pathname;
const output = execFileSync(process.execPath, [cli, '--version'], { encoding: 'utf8' });
assert.match(output, /^share-desk-gpt 0\.1\.0/);
const doctor = execFileSync(process.execPath, [cli, '--doctor'], { encoding: 'utf8' });
assert.match(doctor, /platform:/);
assert.match(doctor, /arch:/);
assert.match(doctor, /node:/);
assert.match(doctor, /PATH entries:/);
console.log('CLI smoke tests passed.');
