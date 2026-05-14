<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

/**
 * MetricsController — Prometheus Metrics Endpoint
 *
 * Endpoint: GET /metrics
 * Dilindungi oleh PrometheusIpWhitelist middleware.
 *
 * Metrik yang disajikan:
 * - app_http_requests_total       : Total HTTP request (counter)
 * - app_http_response_time_ms     : Response time dalam ms (gauge)
 * - app_db_query_count_total      : Total query DB (counter)
 * - app_active_users_total        : Jumlah user aktif (gauge)
 * - app_presensi_sesi_open_total  : Sesi presensi yang sedang terbuka (gauge)
 * - app_uptime_seconds            : Uptime aplikasi dalam detik (gauge)
 * - laravel_info                  : Informasi versi aplikasi (info metric)
 */
class MetricsController extends Controller
{
    /**
     * Kunci cache untuk menyimpan counter metrics secara persisten.
     * Menggunakan database cache (CACHE_STORE=database di .env).
     */
    private const CACHE_TTL    = 3600; // 1 jam
    private const COUNTER_KEY  = 'prometheus_request_counter';
    private const DB_QUERY_KEY = 'prometheus_db_query_counter';

    public function index(Request $request): Response
    {
        $startTime = microtime(true);

        // Ambil data metrik
        $metrics = $this->collectMetrics($request, $startTime);

        // Format sebagai teks Prometheus
        $output = $this->formatPrometheusText($metrics);

        return response($output, 200)
            ->header('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
    }

    /**
     * Kumpulkan semua metrik dari berbagai sumber.
     */
    private function collectMetrics(Request $request, float $startTime): array
    {
        // Increment request counter (disimpan di cache DB)
        $requestCount = $this->incrementCounter(self::COUNTER_KEY);

        // Hitung response time endpoint ini sendiri
        $responseTime = round((microtime(true) - $startTime) * 1000, 2);

        // Data dari database
        $activeUsers      = $this->getActiveUsers();
        $openSessions     = $this->getOpenPresensiSessions();
        $totalPresensi    = $this->getTotalPresensiToday();

        return [
            'request_count'    => $requestCount,
            'response_time_ms' => $responseTime,
            'active_users'     => $activeUsers,
            'open_sessions'    => $openSessions,
            'total_presensi_today' => $totalPresensi,
            'uptime_seconds'   => $this->getUptimeSeconds(),
            'app_version'      => config('app.version', '1.0.0'),
            'app_env'          => config('app.env', 'production'),
        ];
    }

    /**
     * Format data metrik ke format teks Prometheus (text/plain 0.0.4).
     */
    private function formatPrometheusText(array $metrics): string
    {
        $lines = [];

        // ── Informasi Aplikasi ────────────────────────────────────────────
        $lines[] = '# HELP laravel_info Informasi versi aplikasi Laravel';
        $lines[] = '# TYPE laravel_info gauge';
        $lines[] = sprintf(
            'laravel_info{version="%s",env="%s",app="smk_alhafidz"} 1',
            $metrics['app_version'],
            $metrics['app_env']
        );

        // ── HTTP Requests Total ───────────────────────────────────────────
        $lines[] = '';
        $lines[] = '# HELP app_http_requests_total Total HTTP request yang masuk ke endpoint /metrics';
        $lines[] = '# TYPE app_http_requests_total counter';
        $lines[] = sprintf(
            'app_http_requests_total{method="GET",endpoint="/metrics"} %d',
            $metrics['request_count']
        );

        // ── Response Time ─────────────────────────────────────────────────
        $lines[] = '';
        $lines[] = '# HELP app_http_response_time_ms Waktu respons endpoint metrics dalam milidetik';
        $lines[] = '# TYPE app_http_response_time_ms gauge';
        $lines[] = sprintf('app_http_response_time_ms %s', $metrics['response_time_ms']);

        // ── Active Users ──────────────────────────────────────────────────
        $lines[] = '';
        $lines[] = '# HELP app_active_users_total Jumlah user yang aktif (is_active=true)';
        $lines[] = '# TYPE app_active_users_total gauge';
        $lines[] = sprintf('app_active_users_total{role="siswa"} %d', $metrics['active_users']['siswa']);
        $lines[] = sprintf('app_active_users_total{role="guru"} %d', $metrics['active_users']['guru']);
        $lines[] = sprintf('app_active_users_total{role="admin"} %d', $metrics['active_users']['admin']);

        // ── Sesi Presensi ─────────────────────────────────────────────────
        $lines[] = '';
        $lines[] = '# HELP app_presensi_sesi_open_total Jumlah sesi presensi yang sedang terbuka';
        $lines[] = '# TYPE app_presensi_sesi_open_total gauge';
        $lines[] = sprintf('app_presensi_sesi_open_total %d', $metrics['open_sessions']);

        // ── Presensi Hari Ini ─────────────────────────────────────────────
        $lines[] = '';
        $lines[] = '# HELP app_presensi_today_total Jumlah record presensi yang masuk hari ini';
        $lines[] = '# TYPE app_presensi_today_total gauge';
        $lines[] = sprintf('app_presensi_today_total %d', $metrics['total_presensi_today']);

        // ── Uptime ────────────────────────────────────────────────────────
        $lines[] = '';
        $lines[] = '# HELP app_uptime_seconds Uptime aplikasi dalam detik';
        $lines[] = '# TYPE app_uptime_seconds gauge';
        $lines[] = sprintf('app_uptime_seconds %d', $metrics['uptime_seconds']);

        return implode("\n", $lines) . "\n";
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Helper Methods — Ambil data dari database
    // ═══════════════════════════════════════════════════════════════════════

    private function incrementCounter(string $key): int
    {
        $current = Cache::get($key, 0);
        $new     = $current + 1;
        Cache::put($key, $new, self::CACHE_TTL);

        return $new;
    }

    private function getActiveUsers(): array
    {
        try {
            $counts = DB::table('users')
                ->select('role', DB::raw('count(*) as total'))
                ->where('is_active', true)
                ->groupBy('role')
                ->pluck('total', 'role')
                ->toArray();

            return [
                'siswa' => $counts['siswa'] ?? 0,
                'guru'  => $counts['guru']  ?? 0,
                'admin' => $counts['admin'] ?? 0,
            ];
        } catch (\Exception $e) {
            return ['siswa' => 0, 'guru' => 0, 'admin' => 0];
        }
    }

    private function getOpenPresensiSessions(): int
    {
        try {
            return DB::table('presensi_sesis')
                ->where('status', 'terbuka')
                ->whereNull('ditutup_pada')
                ->count();
        } catch (\Exception $e) {
            return 0;
        }
    }

    private function getTotalPresensiToday(): int
    {
        try {
            return DB::table('presensi_details')
                ->whereDate('waktu_isi', today())
                ->count();
        } catch (\Exception $e) {
            return 0;
        }
    }

    private function getUptimeSeconds(): int
    {
        // Gunakan waktu modifikasi file artisan sebagai proxy uptime
        $artisanPath = base_path('artisan');

        if (file_exists($artisanPath)) {
            return (int) (time() - filectime($artisanPath));
        }

        return 0;
    }
}
