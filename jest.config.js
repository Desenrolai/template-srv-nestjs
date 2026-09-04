'use strict';

const { maxWorkers } = require('./scripts/cpu-limit');

/** @type {import('jest').Config} */
module.exports = {
  rootDir: '.',
  roots: ['<rootDir>/src', '<rootDir>/scripts'],
  moduleFileExtensions: ['js', 'json', 'ts'],
  testRegex: '.*\\.spec\\.(ts|js)$',
  // Opcoes do swc vem do .swcrc na raiz — fonte unica com o builder swc.
  transform: {
    '^.+\\.(t|j)s$': ['@swc/jest'],
  },
  collectCoverageFrom: ['src/**/*.(t|j)s'],
  coverageDirectory: 'coverage',
  testEnvironment: 'node',
  // Deriva do cgroup: os.cpus() reporta o host e superdimensiona os workers.
  maxWorkers: maxWorkers(),
};
