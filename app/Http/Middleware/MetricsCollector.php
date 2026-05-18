<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\Response;

class MetricsCollector
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $status = $response->getStatusCode();

        // Rekam jumlah request berdasarkan status HTTP
        if ($status >= 500) {
            $this->incrementCounter('prometheus_error_5xx_counter');
        } elseif ($status >= 400) {
            $this->incrementCounter('prometheus_error_4xx_counter');
        } elseif ($status >= 200 && $status < 300) {
            $this->incrementCounter('prometheus_success_2xx_counter');
        }

        return $response;
    }

    private function incrementCounter(string $key): void
    {
        try {
            $current = Cache::get($key, 0);
            Cache::put($key, $current + 1, 3600);
        } catch (\Exception $e) {
            // Abaikan jika cache gagal
        }
    }
}
