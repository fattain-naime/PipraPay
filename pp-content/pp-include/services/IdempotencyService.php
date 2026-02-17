<?php

declare(strict_types=1);

require_once __DIR__ . '/../repositories/IdempotencyRepository.php';

if (!class_exists('IdempotencyService')) {
    class IdempotencyService
    {
        private IdempotencyRepository $repository;

        public function __construct(?IdempotencyRepository $repository = null)
        {
            $this->repository = $repository ?? new IdempotencyRepository();
        }

        public function acquire(string $scope, string $key, string $requestHash): array
        {
            return $this->repository->acquire($scope, $key, $requestHash);
        }

        public function storeResponse(string $scope, string $key, int $responseCode, array $responseBody): void
        {
            $this->repository->storeResponse($scope, $key, $responseCode, $responseBody);
        }
    }
}