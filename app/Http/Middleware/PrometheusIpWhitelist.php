<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware untuk membatasi akses endpoint /metrics
 * hanya dari IP Prometheus server yang terdaftar di whitelist.
 *
 * Konfigurasi di .env:
 *   PROMETHEUS_ALLOWED_IPS=127.0.0.1,10.0.0.1
 */
class PrometheusIpWhitelist
{
    public function handle(Request $request, Closure $next): Response
    {
        $allowedIps = $this->getAllowedIps();

        // Jika whitelist kosong dan bukan production → izinkan (dev mode)
        if (empty($allowedIps) && app()->environment('local')) {
            return $next($request);
        }

        // Jika whitelist menggunakan wildcard *, izinkan semua (untuk testing/staging)
        if (in_array('*', $allowedIps)) {
            return $next($request);
        }

        $clientIp = $request->ip();

        if (! in_array($clientIp, $allowedIps)) {
            abort(403, 'Akses ke endpoint metrics tidak diizinkan dari IP: ' . $clientIp);
        }

        return $next($request);
    }

    /**
     * Ambil daftar IP yang diizinkan dari environment variable.
     * Format: PROMETHEUS_ALLOWED_IPS=127.0.0.1,10.0.0.5
     */
    private function getAllowedIps(): array
    {
        $envValue = env('PROMETHEUS_ALLOWED_IPS', '127.0.0.1');

        return array_map(
            fn (string $ip) => trim($ip),
            explode(',', $envValue)
        );
    }
}
