<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $data['title'] }}</title>
    <link rel="icon" type="image/png" href="{{ asset('logo.png') }}">
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #333;
            margin: 30px;
            font-size: 13px;
            line-height: 1.5;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 3px double #333;
            padding-bottom: 15px;
        }

        .header h1 {
            margin: 0;
            font-size: 20px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .header p {
            margin: 5px 0 0 0;
            font-size: 11px;
            color: #666;
        }

        .report-title {
            text-align: center;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
            margin-bottom: 20px;
            color: #111;
        }

        .metadata {
            margin-bottom: 15px;
            font-size: 11px;
            color: #555;
            display: flex;
            justify-content: space-between;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }

        th {
            background-color: #f5f5f5;
            color: #000;
            font-weight: bold;
            border: 1px solid #ddd;
            padding: 8px 10px;
            font-size: 11px;
            text-transform: uppercase;
        }

        td {
            border: 1px solid #ddd;
            padding: 8px 10px;
        }

        .text-right {
            text-align: right;
        }

        .text-center {
            text-align: center;
        }

        .total-row {
            font-weight: bold;
            background-color: #fafafa;
        }

        .total-row td {
            border-top: 2px solid #333;
            border-bottom: 2px solid #333;
        }

        .footer {
            margin-top: 50px;
            text-align: right;
            font-size: 11px;
            color: #555;
        }

        .signature-space {
            margin-top: 60px;
            display: inline-block;
            width: 200px;
            border-top: 1px solid #333;
            text-align: center;
            padding-top: 5px;
        }

        @media print {
            body {
                margin: 20px;
            }
            .no-print {
                display: none;
            }
        }
    </style>
</head>
<body>

    <div class="header">
        <img src="{{ asset('logo.png') }}" style="height: 65px; margin-bottom: 10px; object-fit: contain;">
        <h1 style="margin-top: 5px;">Paguyuban Bravo Bekasi</h1>
        <p>Jl. Rawa Tembaga IV No. 04 Telkom Bekasi</p>
    </div>

    <div class="report-title">{{ $data['title'] }}</div>

    <div class="metadata">
        <span>Tanggal Cetak: {{ date('d F Y H:i') }}</span>
        <span>Dicetak Oleh: {{ Auth::user()->name }}</span>
    </div>

    <table>
        <thead>
            @if($type === 'pemasukan')
                <tr>
                    <th width="15%">Tanggal</th>
                    <th width="25%">Nama Anggota</th>
                    <th width="20%">Jenis Transaksi</th>
                    <th>Keterangan</th>
                    <th class="text-right" width="20%">Nominal</th>
                </tr>
            @elseif($type === 'pengeluaran')
                <tr>
                    <th width="15%">Tanggal</th>
                    <th width="25%">Nama Anggota</th>
                    <th width="20%">Jenis Pengeluaran</th>
                    <th>Keterangan/Barang</th>
                    <th class="text-right" width="20%">Nominal</th>
                </tr>
            @elseif($type === 'saldo_anggota')
                <tr>
                    <th width="20%">NIK</th>
                    <th>Nama Anggota</th>
                    <th width="35%">Email</th>
                    <th class="text-right" width="25%">Total Simpanan</th>
                </tr>
            @elseif($type === 'pinjaman_anggota')
                <tr>
                    <th width="20%">NIK</th>
                    <th>Nama Anggota</th>
                    <th class="text-right" width="25%">Total Pinjam/Kredit</th>
                    <th class="text-right" width="25%">Sisa Hutang</th>
                </tr>
            @elseif($type === 'rekap_anggota')
                <tr>
                    <th width="12%">NIK</th>
                    <th width="20%">Nama Anggota</th>
                    <th class="text-right" width="16%">Total Simpanan</th>
                    <th class="text-right" width="16%">Total Pinjaman</th>
                    <th>Detail Pinjaman / Kredit Berjalan</th>
                </tr>
            @endif
        </thead>
        <tbody>
            @php $totalSum = 0; $totalSisa = 0; @endphp

            @forelse($data['items'] as $item)
                @if($type === 'pemasukan' || $type === 'pengeluaran')
                    <tr>
                        <td class="text-center">{{ $item['tanggal'] }}</td>
                        <td>{{ $item['anggota'] }}</td>
                        <td>{{ $item['jenis'] }}</td>
                        <td>{{ $item['keterangan'] }}</td>
                        <td class="text-right">Rp {{ number_format($item['nominal'], 0, ',', '.') }}</td>
                    </tr>
                    @php $totalSum += $item['nominal']; @endphp
                @elseif($type === 'saldo_anggota')
                    <tr>
                        <td class="text-center">{{ $item['nik'] }}</td>
                        <td>{{ $item['anggota'] }}</td>
                        <td>{{ $item['email'] }}</td>
                        <td class="text-right">Rp {{ number_format($item['nominal'], 0, ',', '.') }}</td>
                    </tr>
                    @php $totalSum += $item['nominal']; @endphp
                @elseif($type === 'pinjaman_anggota')
                    <tr>
                        <td class="text-center">{{ $item['nik'] }}</td>
                        <td>{{ $item['anggota'] }}</td>
                        <td class="text-right">Rp {{ number_format($item['total_pinjam'], 0, ',', '.') }}</td>
                        <td class="text-right">Rp {{ number_format($item['sisa_pinjam'], 0, ',', '.') }}</td>
                    </tr>
                    @php 
                        $totalSum += $item['total_pinjam']; 
                        $totalSisa += $item['sisa_pinjam']; 
                    @endphp
                @elseif($type === 'rekap_anggota')
                    <tr>
                        <td class="text-center">{{ $item['nik'] }}</td>
                        <td><strong>{{ $item['anggota'] }}</strong><br><span style="font-size: 10px; color: #666;">{{ $item['email'] }}</span></td>
                        <td class="text-right">Rp {{ number_format($item['total_simpanan'], 0, ',', '.') }}</td>
                        <td class="text-right">Rp {{ number_format($item['total_pinjaman'], 0, ',', '.') }}</td>
                        <td>
                            @if(count($item['pinjaman']) > 0)
                                <table style="width: 100%; border: none; margin: 0; font-size: 11px;">
                                    <thead>
                                        <tr style="background: transparent;">
                                            <th style="border: none; padding: 2px; text-align: center; font-size: 10px; color: #555;" width="33%">Tenor</th>
                                            <th style="border: none; padding: 2px; text-align: center; font-size: 10px; color: #555;" width="33%">Bulan Ke-</th>
                                            <th style="border: none; padding: 2px; text-align: right; font-size: 10px; color: #555;" width="34%">Sisa</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach($item['pinjaman'] as $pj)
                                            <tr>
                                                <td style="border: none; padding: 3px 2px;" class="text-center">{{ $pj['tenor'] }} Bln</td>
                                                <td style="border: none; padding: 3px 2px;" class="text-center">{{ $pj['bulan_ke'] }}</td>
                                                <td style="border: none; padding: 3px 2px;" class="text-right">Rp {{ number_format($pj['sisa'], 0, ',', '.') }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            @else
                                <span style="color: #999; font-style: italic;">Tidak ada pinjaman aktif</span>
                            @endif
                        </td>
                    </tr>
                    @php 
                        $totalSum += $item['total_simpanan']; 
                        $totalSisa += $item['total_pinjaman']; 
                    @endphp
                @endif
            @empty
                <tr>
                    <td colspan="5" class="text-center" style="padding: 20px 0;">Tidak ada data laporan ditemukan.</td>
                </tr>
            @endforelse

            <!-- Total Row -->
            @if($type === 'pemasukan' || $type === 'pengeluaran' || $type === 'saldo_anggota')
                <tr class="total-row">
                    <td colspan="{{ $type === 'saldo_anggota' ? 3 : 4 }}" class="text-right">Total Keseluruhan:</td>
                    <td class="text-right">Rp {{ number_format($totalSum, 0, ',', '.') }}</td>
                </tr>
            @elseif($type === 'pinjaman_anggota')
                <tr class="total-row">
                    <td colspan="2" class="text-right">Total Keseluruhan:</td>
                    <td class="text-right">Rp {{ number_format($totalSum, 0, ',', '.') }}</td>
                    <td class="text-right">Rp {{ number_format($totalSisa, 0, ',', '.') }}</td>
                </tr>
            @elseif($type === 'rekap_anggota')
                <tr class="total-row">
                    <td colspan="2" class="text-right">Total Keseluruhan:</td>
                    <td class="text-right">Rp {{ number_format($totalSum, 0, ',', '.') }}</td>
                    <td class="text-right">Rp {{ number_format($totalSisa, 0, ',', '.') }}</td>
                    <td></td>
                </tr>
            @endif
        </tbody>
    </table>

    <div class="footer">
        <div style="display: inline-block; text-align: center; width: 200px; font-size: 11px;">
            <div>Bekasi, {{ date('d F Y') }}</div>
            <div style="margin-bottom: 45px;">Pengurus Koperasi,</div>
            
            <div style="position: relative; width: 100%;">
                @if(Auth::user()->signature)
                    <img src="{{ asset('storage/' . Auth::user()->signature) }}" style="max-height: 55px; object-fit: contain; margin: 0 auto; display: block; position: absolute; left: 50%; transform: translateX(-50%); top: -45px; z-index: 10;">
                @endif
                <div style="border-top: 1px solid #333; padding-top: 5px; font-weight: bold; width: 100%;">
                    {{ Auth::user()->name }}
                </div>
            </div>
        </div>
    </div>

    <!-- Automatically Trigger Print -->
    <script>
        window.onload = function() {
            window.print();
        }
    </script>
</body>
</html>
