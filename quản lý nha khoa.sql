```sql
/* ============================================================
   HỆ THỐNG QUẢN LÝ PHÒNG KHÁM NHA KHOA
   HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU: MICROSOFT SQL SERVER

   Người xây dựng: Hệ thống quản lý nha khoa
   Ngôn ngữ: SQL Server
   ============================================================ */


/* ============================================================
   PHẦN 1. XÓA CƠ SỞ DỮ LIỆU CŨ NẾU ĐÃ TỒN TẠI
   ============================================================ */

USE MASTER;
GO

IF DB_ID(N'QuanLyPhongKhamNhaKhoa') IS NOT NULL
BEGIN
    ALTER DATABASE QuanLyPhongKhamNhaKhoa
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE QuanLyPhongKhamNhaKhoa;
END;
GO


/* ============================================================
   PHẦN 2. TẠO CƠ SỞ DỮ LIỆU
   ============================================================ */

CREATE DATABASE QuanLyPhongKhamNhaKhoa;
GO

USE QuanLyPhongKhamNhaKhoa;
GO


/* ============================================================
   PHẦN 3. BẢNG BỆNH NHÂN
   ============================================================ */

CREATE TABLE BenhNhan
(
    MaBenhNhan INT IDENTITY(1,1) PRIMARY KEY,

    HoTen NVARCHAR(100) NOT NULL,

    NgaySinh DATE,

    GioiTinh NVARCHAR(10),

    SoDienThoai VARCHAR(15),

    Email VARCHAR(100),

    DiaChi NVARCHAR(255),

    NgheNghiep NVARCHAR(100),

    TienSuBenh NVARCHAR(MAX),

    DiUng NVARCHAR(MAX),

    NgayTao DATETIME NOT NULL
        DEFAULT GETDATE(),

    TrangThai BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_BenhNhan_GioiTinh
        CHECK
        (
            GioiTinh IS NULL
            OR GioiTinh IN
            (
                N'Nam',
                N'Nữ',
                N'Khác'
            )
        )
);
GO


/* ============================================================
   PHẦN 4. BẢNG BÁC SĨ
   ============================================================ */

CREATE TABLE BacSi
(
    MaBacSi INT IDENTITY(1,1) PRIMARY KEY,

    HoTen NVARCHAR(100) NOT NULL,

    NgaySinh DATE,

    GioiTinh NVARCHAR(10),

    SoDienThoai VARCHAR(15),

    Email VARCHAR(100),

    DiaChi NVARCHAR(255),

    ChuyenKhoa NVARCHAR(100),

    BangCap NVARCHAR(255),

    NamKinhNghiem INT,

    NgayVaoLam DATE,

    TrangThai BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_BacSi_GioiTinh
        CHECK
        (
            GioiTinh IS NULL
            OR GioiTinh IN
            (
                N'Nam',
                N'Nữ',
                N'Khác'
            )
        ),

    CONSTRAINT CK_BacSi_KinhNghiem
        CHECK
        (
            NamKinhNghiem IS NULL
            OR NamKinhNghiem >= 0
        )
);
GO


/* ============================================================
   PHẦN 5. BẢNG NHÂN VIÊN
   ============================================================ */

CREATE TABLE NhanVien
(
    MaNhanVien INT IDENTITY(1,1) PRIMARY KEY,

    HoTen NVARCHAR(100) NOT NULL,

    NgaySinh DATE,

    GioiTinh NVARCHAR(10),

    SoDienThoai VARCHAR(15),

    Email VARCHAR(100),

    DiaChi NVARCHAR(255),

    ChucVu NVARCHAR(100),

    NgayVaoLam DATE,

    Luong DECIMAL(18,2),

    TrangThai BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_NhanVien_GioiTinh
        CHECK
        (
            GioiTinh IS NULL
            OR GioiTinh IN
            (
                N'Nam',
                N'Nữ',
                N'Khác'
            )
        ),

    CONSTRAINT CK_NhanVien_Luong
        CHECK
        (
            Luong IS NULL OR Luong >= 0
        )
);
GO


/* ============================================================
   PHẦN 6. BẢNG PHÒNG KHÁM
   ============================================================ */

CREATE TABLE PhongKham
(
    MaPhong INT IDENTITY(1,1) PRIMARY KEY,

    TenPhong NVARCHAR(100) NOT NULL UNIQUE,

    ViTri NVARCHAR(255),

    MoTa NVARCHAR(500),

    TrangThai BIT NOT NULL
        DEFAULT 1
);
GO


/* ============================================================
   PHẦN 7. BẢNG GHẾ NHA KHOA
   ============================================================ */

CREATE TABLE GheNhaKhoa
(
    MaGhe INT IDENTITY(1,1) PRIMARY KEY,

    MaPhong INT NOT NULL,

    TenGhe NVARCHAR(100) NOT NULL,

    TrangThai NVARCHAR(30)
        NOT NULL
        DEFAULT N'Trống',

    CONSTRAINT FK_GheNhaKhoa_Phong
        FOREIGN KEY (MaPhong)
        REFERENCES PhongKham(MaPhong),

    CONSTRAINT CK_GheNhaKhoa_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Trống',
                N'Đang sử dụng',
                N'Bảo trì'
            )
        )
);
GO


/* ============================================================
   PHẦN 8. BẢNG DỊCH VỤ NHA KHOA
   ============================================================ */

CREATE TABLE DichVu
(
    MaDichVu INT IDENTITY(1,1) PRIMARY KEY,

    TenDichVu NVARCHAR(150) NOT NULL UNIQUE,

    MoTa NVARCHAR(500),

    DonGia DECIMAL(18,2) NOT NULL,

    ThoiGianDuKien INT,

    TrangThai BIT NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_DichVu_DonGia
        CHECK (DonGia >= 0),

    CONSTRAINT CK_DichVu_ThoiGian
        CHECK
        (
            ThoiGianDuKien IS NULL
            OR ThoiGianDuKien > 0
        )
);
GO


/* ============================================================
   PHẦN 9. BẢNG RĂNG
   ============================================================ */

CREATE TABLE Rang
(
    MaRang INT IDENTITY(1,1) PRIMARY KEY,

    SoRang INT NOT NULL,

    TenRang NVARCHAR(100),

    ViTri NVARCHAR(100),

    MoTa NVARCHAR(500),

    CONSTRAINT UQ_Rang_SoRang
        UNIQUE (SoRang)
);
GO


/* ============================================================
   PHẦN 10. BẢNG LỊCH HẸN
   ============================================================ */

CREATE TABLE LichHen
(
    MaLichHen INT IDENTITY(1,1) PRIMARY KEY,

    MaBenhNhan INT NOT NULL,

    MaBacSi INT NOT NULL,

    MaPhong INT,

    MaGhe INT,

    ThoiGianHen DATETIME NOT NULL,

    LyDoHen NVARCHAR(500),

    TrangThai NVARCHAR(30)
        NOT NULL
        DEFAULT N'Chờ khám',

    GhiChu NVARCHAR(500),

    NgayTao DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT FK_LichHen_BenhNhan
        FOREIGN KEY (MaBenhNhan)
        REFERENCES BenhNhan(MaBenhNhan),

    CONSTRAINT FK_LichHen_BacSi
        FOREIGN KEY (MaBacSi)
        REFERENCES BacSi(MaBacSi),

    CONSTRAINT FK_LichHen_Phong
        FOREIGN KEY (MaPhong)
        REFERENCES PhongKham(MaPhong),

    CONSTRAINT FK_LichHen_Ghe
        FOREIGN KEY (MaGhe)
        REFERENCES GheNhaKhoa(MaGhe),

    CONSTRAINT CK_LichHen_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Chờ khám',
                N'Đã xác nhận',
                N'Đã khám',
                N'Đã hủy',
                N'Không đến'
            )
        )
);
GO


/* ============================================================
   PHẦN 11. BẢNG PHIẾU KHÁM
   ============================================================ */

CREATE TABLE PhieuKham
(
    MaPhieuKham INT IDENTITY(1,1) PRIMARY KEY,

    MaBenhNhan INT NOT NULL,

    MaBacSi INT NOT NULL,

    MaLichHen INT,

    NgayKham DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    LyDoKham NVARCHAR(500),

    ChanDoan NVARCHAR(MAX),

    KetLuan NVARCHAR(MAX),

    HuongDieuTri NVARCHAR(MAX),

    GhiChu NVARCHAR(MAX),

    CONSTRAINT FK_PhieuKham_BenhNhan
        FOREIGN KEY (MaBenhNhan)
        REFERENCES BenhNhan(MaBenhNhan),

    CONSTRAINT FK_PhieuKham_BacSi
        FOREIGN KEY (MaBacSi)
        REFERENCES BacSi(MaBacSi),

    CONSTRAINT FK_PhieuKham_LichHen
        FOREIGN KEY (MaLichHen)
        REFERENCES LichHen(MaLichHen)
);
GO


/* ============================================================
   PHẦN 12. BẢNG CHI TIẾT KHÁM RĂNG
   ============================================================ */

CREATE TABLE ChiTietKhamRang
(
    MaChiTiet INT IDENTITY(1,1) PRIMARY KEY,

    MaPhieuKham INT NOT NULL,

    MaRang INT NOT NULL,

    TinhTrang NVARCHAR(500),

    ChanDoan NVARCHAR(500),

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_ChiTietKhamRang_Phieu
        FOREIGN KEY (MaPhieuKham)
        REFERENCES PhieuKham(MaPhieuKham),

    CONSTRAINT FK_ChiTietKhamRang_Rang
        FOREIGN KEY (MaRang)
        REFERENCES Rang(MaRang)
);
GO


/* ============================================================
   PHẦN 13. BẢNG ĐIỀU TRỊ
   ============================================================ */

CREATE TABLE DieuTri
(
    MaDieuTri INT IDENTITY(1,1) PRIMARY KEY,

    MaPhieuKham INT NOT NULL,

    MaBacSi INT NOT NULL,

    MaRang INT,

    TenDieuTri NVARCHAR(200) NOT NULL,

    MoTa NVARCHAR(MAX),

    NgayBatDau DATETIME,

    NgayKetThuc DATETIME,

    TrangThai NVARCHAR(30)
        NOT NULL
        DEFAULT N'Đang điều trị',

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_DieuTri_PhieuKham
        FOREIGN KEY (MaPhieuKham)
        REFERENCES PhieuKham(MaPhieuKham),

    CONSTRAINT FK_DieuTri_BacSi
        FOREIGN KEY (MaBacSi)
        REFERENCES BacSi(MaBacSi),

    CONSTRAINT FK_DieuTri_Rang
        FOREIGN KEY (MaRang)
        REFERENCES Rang(MaRang),

    CONSTRAINT CK_DieuTri_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Đang điều trị',
                N'Hoàn thành',
                N'Tạm dừng',
                N'Hủy'
            )
        )
);
GO


/* ============================================================
   PHẦN 14. BẢNG CHI TIẾT DỊCH VỤ ĐIỀU TRỊ
   ============================================================ */

CREATE TABLE ChiTietDichVu
(
    MaChiTietDichVu INT IDENTITY(1,1) PRIMARY KEY,

    MaDieuTri INT NOT NULL,

    MaDichVu INT NOT NULL,

    SoLuong INT NOT NULL
        DEFAULT 1,

    DonGia DECIMAL(18,2) NOT NULL,

    ThanhTien AS
    (
        SoLuong * DonGia
    ) PERSISTED,

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_ChiTietDichVu_DieuTri
        FOREIGN KEY (MaDieuTri)
        REFERENCES DieuTri(MaDieuTri),

    CONSTRAINT FK_ChiTietDichVu_DichVu
        FOREIGN KEY (MaDichVu)
        REFERENCES DichVu(MaDichVu),

    CONSTRAINT CK_ChiTietDichVu_SoLuong
        CHECK (SoLuong > 0),

    CONSTRAINT CK_ChiTietDichVu_DonGia
        CHECK (DonGia >= 0)
);
GO


/* ============================================================
   PHẦN 15. BẢNG THUỐC
   ============================================================ */

CREATE TABLE Thuoc
(
    MaThuoc INT IDENTITY(1,1) PRIMARY KEY,

    TenThuoc NVARCHAR(200) NOT NULL,

    DonViTinh NVARCHAR(50),

    DonGia DECIMAL(18,2),

    SoLuongTon INT
        DEFAULT 0,

    HuongDanSuDung NVARCHAR(500),

    TrangThai BIT
        NOT NULL
        DEFAULT 1,

    CONSTRAINT CK_Thuoc_DonGia
        CHECK
        (
            DonGia IS NULL OR DonGia >= 0
        ),

    CONSTRAINT CK_Thuoc_SoLuongTon
        CHECK
        (
            SoLuongTon >= 0
        )
);
GO


/* ============================================================
   PHẦN 16. BẢNG ĐƠN THUỐC
   ============================================================ */

CREATE TABLE DonThuoc
(
    MaDonThuoc INT IDENTITY(1,1) PRIMARY KEY,

    MaPhieuKham INT NOT NULL,

    MaBacSi INT NOT NULL,

    NgayKe DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    LoiDan NVARCHAR(MAX),

    CONSTRAINT FK_DonThuoc_PhieuKham
        FOREIGN KEY (MaPhieuKham)
        REFERENCES PhieuKham(MaPhieuKham),

    CONSTRAINT FK_DonThuoc_BacSi
        FOREIGN KEY (MaBacSi)
        REFERENCES BacSi(MaBacSi)
);
GO


/* ============================================================
   PHẦN 17. BẢNG CHI TIẾT ĐƠN THUỐC
   ============================================================ */

CREATE TABLE ChiTietDonThuoc
(
    MaChiTietDonThuoc INT IDENTITY(1,1) PRIMARY KEY,

    MaDonThuoc INT NOT NULL,

    MaThuoc INT NOT NULL,

    SoLuong INT NOT NULL,

    LieuDung NVARCHAR(255),

    SoNgayDung INT,

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_ChiTietDonThuoc_DonThuoc
        FOREIGN KEY (MaDonThuoc)
        REFERENCES DonThuoc(MaDonThuoc),

    CONSTRAINT FK_ChiTietDonThuoc_Thuoc
        FOREIGN KEY (MaThuoc)
        REFERENCES Thuoc(MaThuoc),

    CONSTRAINT CK_ChiTietDonThuoc_SoLuong
        CHECK (SoLuong > 0),

    CONSTRAINT CK_ChiTietDonThuoc_SoNgay
        CHECK
        (
            SoNgayDung IS NULL OR SoNgayDung > 0
        )
);
GO


/* ============================================================
   PHẦN 18. BẢNG HÓA ĐƠN
   ============================================================ */

CREATE TABLE HoaDon
(
    MaHoaDon INT IDENTITY(1,1) PRIMARY KEY,

    MaBenhNhan INT NOT NULL,

    MaPhieuKham INT,

    NgayLap DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    TongTien DECIMAL(18,2)
        NOT NULL
        DEFAULT 0,

    GiamGia DECIMAL(18,2)
        NOT NULL
        DEFAULT 0,

    ThanhTien AS
    (
        TongTien - GiamGia
    ) PERSISTED,

    TrangThai NVARCHAR(30)
        NOT NULL
        DEFAULT N'Chưa thanh toán',

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_HoaDon_BenhNhan
        FOREIGN KEY (MaBenhNhan)
        REFERENCES BenhNhan(MaBenhNhan),

    CONSTRAINT FK_HoaDon_PhieuKham
        FOREIGN KEY (MaPhieuKham)
        REFERENCES PhieuKham(MaPhieuKham),

    CONSTRAINT CK_HoaDon_TongTien
        CHECK (TongTien >= 0),

    CONSTRAINT CK_HoaDon_GiamGia
        CHECK (GiamGia >= 0),

    CONSTRAINT CK_HoaDon_TrangThai
        CHECK
        (
            TrangThai IN
            (
                N'Chưa thanh toán',
                N'Đã thanh toán',
                N'Đã hủy'
            )
        )
);
GO


/* ============================================================
   PHẦN 19. BẢNG CHI TIẾT HÓA ĐƠN
   ============================================================ */

CREATE TABLE ChiTietHoaDon
(
    MaChiTietHoaDon INT IDENTITY(1,1) PRIMARY KEY,

    MaHoaDon INT NOT NULL,

    MaDichVu INT,

    NoiDung NVARCHAR(255) NOT NULL,

    SoLuong INT NOT NULL
        DEFAULT 1,

    DonGia DECIMAL(18,2) NOT NULL,

    ThanhTien AS
    (
        SoLuong * DonGia
    ) PERSISTED,

    CONSTRAINT FK_ChiTietHoaDon_HoaDon
        FOREIGN KEY (MaHoaDon)
        REFERENCES HoaDon(MaHoaDon),

    CONSTRAINT FK_ChiTietHoaDon_DichVu
        FOREIGN KEY (MaDichVu)
        REFERENCES DichVu(MaDichVu),

    CONSTRAINT CK_ChiTietHoaDon_SoLuong
        CHECK (SoLuong > 0),

    CONSTRAINT CK_ChiTietHoaDon_DonGia
        CHECK (DonGia >= 0)
);
GO


/* ============================================================
   PHẦN 20. BẢNG THANH TOÁN
   ============================================================ */

CREATE TABLE ThanhToan
(
    MaThanhToan INT IDENTITY(1,1) PRIMARY KEY,

    MaHoaDon INT NOT NULL,

    SoTien DECIMAL(18,2) NOT NULL,

    PhuongThuc NVARCHAR(50) NOT NULL,

    NgayThanhToan DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    MaNhanVien INT,

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_ThanhToan_HoaDon
        FOREIGN KEY (MaHoaDon)
        REFERENCES HoaDon(MaHoaDon),

    CONSTRAINT FK_ThanhToan_NhanVien
        FOREIGN KEY (MaNhanVien)
        REFERENCES NhanVien(MaNhanVien),

    CONSTRAINT CK_ThanhToan_SoTien
        CHECK (SoTien > 0),

    CONSTRAINT CK_ThanhToan_PhuongThuc
        CHECK
        (
            PhuongThuc IN
            (
                N'Tiền mặt',
                N'Chuyển khoản',
                N'Thẻ',
                N'Ví điện tử'
            )
        )
);
GO


/* ============================================================
   PHẦN 21. BẢNG TÀI KHOẢN
   ============================================================ */

CREATE TABLE TaiKhoan
(
    MaTaiKhoan INT IDENTITY(1,1) PRIMARY KEY,

    TenDangNhap VARCHAR(50) NOT NULL UNIQUE,

    MatKhau VARCHAR(255) NOT NULL,

    VaiTro NVARCHAR(30) NOT NULL,

    MaBacSi INT,

    MaNhanVien INT,

    NgayTao DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    TrangThai BIT
        NOT NULL
        DEFAULT 1,

    CONSTRAINT FK_TaiKhoan_BacSi
        FOREIGN KEY (MaBacSi)
        REFERENCES BacSi(MaBacSi),

    CONSTRAINT FK_TaiKhoan_NhanVien
        FOREIGN KEY (MaNhanVien)
        REFERENCES NhanVien(MaNhanVien),

    CONSTRAINT CK_TaiKhoan_VaiTro
        CHECK
        (
            VaiTro IN
            (
                N'Quản trị viên',
                N'Bác sĩ',
                N'Lễ tân',
                N'Nhân viên'
            )
        )
);
GO


/* ============================================================
   PHẦN 22. BẢNG NHẬT KÝ HỆ THỐNG
   ============================================================ */

CREATE TABLE NhatKyHeThong
(
    MaNhatKy BIGINT IDENTITY(1,1) PRIMARY KEY,

    MaTaiKhoan INT,

    HanhDong NVARCHAR(100),

    NoiDung NVARCHAR(MAX),

    ThoiGian DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    DiaChiMayTinh VARCHAR(50),

    CONSTRAINT FK_NhatKy_TaiKhoan
        FOREIGN KEY (MaTaiKhoan)
        REFERENCES TaiKhoan(MaTaiKhoan)
);
GO


/* ============================================================
   PHẦN 23. DỮ LIỆU PHÒNG KHÁM
   ============================================================ */

INSERT INTO PhongKham
(
    TenPhong,
    ViTri,
    MoTa
)
VALUES
(
    N'Phòng khám số 1',
    N'Tầng 1',
    N'Phòng khám tổng quát'
),
(
    N'Phòng điều trị số 1',
    N'Tầng 1',
    N'Phòng điều trị nha khoa'
),
(
    N'Phòng phẫu thuật',
    N'Tầng 2',
    N'Phòng tiểu phẫu nha khoa'
);
GO


/* ============================================================
   PHẦN 24. DỮ LIỆU GHẾ NHA KHOA
   ============================================================ */

INSERT INTO GheNhaKhoa
(
    MaPhong,
    TenGhe,
    TrangThai
)
VALUES
(1, N'Ghế số 1', N'Trống'),
(1, N'Ghế số 2', N'Trống'),
(2, N'Ghế điều trị số 1', N'Trống'),
(2, N'Ghế điều trị số 2', N'Trống'),
(3, N'Ghế phẫu thuật số 1', N'Trống');
GO


/* ============================================================
   PHẦN 25. DỮ LIỆU BÁC SĨ
   ============================================================ */

INSERT INTO BacSi
(
    HoTen,
    NgaySinh,
    GioiTinh,
    SoDienThoai,
    Email,
    ChuyenKhoa,
    BangCap,
    NamKinhNghiem,
    NgayVaoLam
)
VALUES
(
    N'Nguyễn Văn An',
    '1985-05-10',
    N'Nam',
    '0912345678',
    'an@nhakhoa.vn',
    N'Nha khoa tổng quát',
    N'Bác sĩ Răng Hàm Mặt',
    10,
    '2018-01-01'
),
(
    N'Trần Thị Mai',
    '1990-08-20',
    N'Nữ',
    '0923456789',
    'mai@nhakhoa.vn',
    N'Chỉnh nha',
    N'Bác sĩ Răng Hàm Mặt',
    7,
    '2020-03-01'
);
GO


/* ============================================================
   PHẦN 26. DỮ LIỆU NHÂN VIÊN
   ============================================================ */

INSERT INTO NhanVien
(
    HoTen,
    NgaySinh,
    GioiTinh,
    SoDienThoai,
    Email,
    ChucVu,
    NgayVaoLam,
    Luong
)
VALUES
(
    N'Lê Thị Hoa',
    '1995-04-12',
    N'Nữ',
    '0934567890',
    'hoa@nhakhoa.vn',
    N'Lễ tân',
    '2022-01-10',
    8000000
),
(
    N'Phạm Văn Bình',
    '1992-09-15',
    N'Nam',
    '0945678901',
    'binh@nhakhoa.vn',
    N'Nhân viên',
    '2021-06-01',
    9000000
);
GO


/* ============================================================
   PHẦN 27. DỮ LIỆU BỆNH NHÂN
   ============================================================ */

INSERT INTO BenhNhan
(
    HoTen,
    NgaySinh,
    GioiTinh,
    SoDienThoai,
    Email,
    DiaChi,
    NgheNghiep,
    TienSuBenh,
    DiUng
)
VALUES
(
    N'Phạm Minh Khoa',
    '2000-02-15',
    N'Nam',
    '0987654321',
    'khoa@gmail.com',
    N'Ninh Bình',
    N'Sinh viên',
    N'Không',
    N'Không'
),
(
    N'Nguyễn Thị Lan',
    '1998-10-20',
    N'Nữ',
    '0976543210',
    'lan@gmail.com',
    N'Hà Nội',
    N'Giáo viên',
    N'Không',
    N'Không'
);
GO


/* ============================================================
   PHẦN 28. DỮ LIỆU DỊCH VỤ
   ============================================================ */

INSERT INTO DichVu
(
    TenDichVu,
    MoTa,
    DonGia,
    ThoiGianDuKien
)
VALUES
(
    N'Khám răng tổng quát',
    N'Khám và kiểm tra tình trạng răng miệng',
    100000,
    30
),
(
    N'Lấy cao răng',
    N'Làm sạch cao răng',
    300000,
    45
),
(
    N'Trám răng',
    N'Trám phục hồi răng sâu',
    500000,
    60
),
(
    N'Nhổ răng',
    N'Tiểu phẫu nhổ răng',
    800000,
    60
),
(
    N'Niềng răng',
    N'Điều trị chỉnh nha',
    30000000,
    60
),
(
    N'Chụp X-quang',
    N'Chụp X-quang răng',
    200000,
    15
);
GO


/* ============================================================
   PHẦN 29. DỮ LIỆU RĂNG
   ============================================================ */

INSERT INTO Rang
(
    SoRang,
    TenRang,
    ViTri
)
VALUES
(11, N'Răng cửa giữa hàm trên phải', N'Hàm trên bên phải'),
(12, N'Răng cửa bên hàm trên phải', N'Hàm trên bên phải'),
(21, N'Răng cửa giữa hàm trên trái', N'Hàm trên bên trái'),
(22, N'Răng cửa bên hàm trên trái', N'Hàm trên bên trái'),
(31, N'Răng cửa giữa hàm dưới trái', N'Hàm dưới bên trái'),
(32, N'Răng cửa bên hàm dưới trái', N'Hàm dưới bên trái'),
(41, N'Răng cửa giữa hàm dưới phải', N'Hàm dưới bên phải'),
(42, N'Răng cửa bên hàm dưới phải', N'Hàm dưới bên phải'),
(16, N'Răng hàm lớn thứ nhất hàm trên phải', N'Hàm trên bên phải'),
(26, N'Răng hàm lớn thứ nhất hàm trên trái', N'Hàm trên bên trái'),
(36, N'Răng hàm lớn thứ nhất hàm dưới trái', N'Hàm dưới bên trái'),
(46, N'Răng hàm lớn thứ nhất hàm dưới phải', N'Hàm dưới bên phải');
GO


/* ============================================================
   PHẦN 30. DỮ LIỆU THUỐC
   ============================================================ */

INSERT INTO Thuoc
(
    TenThuoc,
    DonViTinh,
    DonGia,
    SoLuongTon,
    HuongDanSuDung
)
VALUES
(
    N'Paracetamol 500mg',
    N'Viên',
    1000,
    500,
    N'Uống theo chỉ định của bác sĩ'
),
(
    N'Amoxicillin 500mg',
    N'Viên',
    2000,
    300,
    N'Dùng theo đơn thuốc'
),
(
    N'Ibuprofen 400mg',
    N'Viên',
    1500,
    400,
    N'Uống sau khi ăn theo chỉ định'
);
GO


/* ============================================================
   PHẦN 31. DỮ LIỆU LỊCH HẸN
   ============================================================ */

INSERT INTO LichHen
(
    MaBenhNhan,
    MaBacSi,
    MaPhong,
    MaGhe,
    ThoiGianHen,
    LyDoHen,
    TrangThai
)
VALUES
(
    1,
    1,
    1,
    1,
    '2026-09-01 08:00:00',
    N'Khám răng tổng quát',
    N'Đã xác nhận'
),
(
    2,
    2,
    2,
    3,
    '2026-09-01 09:30:00',
    N'Tư vấn chỉnh nha',
    N'Chờ khám'
);
GO


/* ============================================================
   PHẦN 32. DỮ LIỆU PHIẾU KHÁM
   ============================================================ */

INSERT INTO PhieuKham
(
    MaBenhNhan,
    MaBacSi,
    MaLichHen,
    NgayKham,
    LyDoKham,
    ChanDoan,
    KetLuan,
    HuongDieuTri
)
VALUES
(
    1,
    1,
    1,
    '2026-09-01 08:05:00',
    N'Đau răng hàm',
    N'Sâu răng hàm dưới',
    N'Cần điều trị răng sâu',
    N'Trám răng và theo dõi'
);
GO


/* ============================================================
   PHẦN 33. CHI TIẾT KHÁM RĂNG
   ============================================================ */

INSERT INTO ChiTietKhamRang
(
    MaPhieuKham,
    MaRang,
    TinhTrang,
    ChanDoan,
    GhiChu
)
VALUES
(
    1,
    46,
    N'Có dấu hiệu sâu răng',
    N'Sâu răng',
    N'Cần điều trị'
);
GO


/* ============================================================
   PHẦN 34. DỮ LIỆU ĐIỀU TRỊ
   ============================================================ */

INSERT INTO DieuTri
(
    MaPhieuKham,
    MaBacSi,
    MaRang,
    TenDieuTri,
    MoTa,
    NgayBatDau,
    TrangThai
)
VALUES
(
    1,
    1,
    46,
    N'Trám răng',
    N'Trám phục hồi răng sâu',
    '2026-09-01 08:30:00',
    N'Hoàn thành'
);
GO


/* ============================================================
   PHẦN 35. CHI TIẾT DỊCH VỤ
   ============================================================ */

INSERT INTO ChiTietDichVu
(
    MaDieuTri,
    MaDichVu,
    SoLuong,
    DonGia,
    GhiChu
)
VALUES
(
    1,
    3,
    1,
    500000,
    N'Trám răng số 46'
);
GO


/* ============================================================
   PHẦN 36. ĐƠN THUỐC
   ============================================================ */

INSERT INTO DonThuoc
(
    MaPhieuKham,
    MaBacSi,
    LoiDan
)
VALUES
(
    1,
    1,
    N'Uống thuốc đúng liều và tái khám khi có triệu chứng bất thường'
);
GO


/* ============================================================
   PHẦN 37. CHI TIẾT ĐƠN THUỐC
   ============================================================ */

INSERT INTO ChiTietDonThuoc
(
    MaDonThuoc,
    MaThuoc,
    SoLuong,
    LieuDung,
    SoNgayDung
)
VALUES
(
    1,
    1,
    6,
    N'Ngày uống 2 lần, mỗi lần 1 viên',
    3
);
GO


/* ============================================================
   PHẦN 38. HÓA ĐƠN
   ============================================================ */

INSERT INTO HoaDon
(
    MaBenhNhan,
    MaPhieuKham,
    TongTien,
    GiamGia,
    TrangThai
)
VALUES
(
    1,
    1,
    500000,
    0,
    N'Đã thanh toán'
);
GO


/* ============================================================
   PHẦN 39. CHI TIẾT HÓA ĐƠN
   ============================================================ */

INSERT INTO ChiTietHoaDon
(
    MaHoaDon,
    MaDichVu,
    NoiDung,
    SoLuong,
    DonGia
)
VALUES
(
    1,
    3,
    N'Trám răng',
    1,
    500000
);
GO


/* ============================================================
   PHẦN 40. THANH TOÁN
   ============================================================ */

INSERT INTO ThanhToan
(
    MaHoaDon,
    SoTien,
    PhuongThuc,
    MaNhanVien,
    GhiChu
)
VALUES
(
    1,
    500000,
    N'Tiền mặt',
    1,
    N'Thanh toán đầy đủ'
);
GO


/* ============================================================
   PHẦN 41. TÀI KHOẢN
   ============================================================ */

INSERT INTO TaiKhoan
(
    TenDangNhap,
    MatKhau,
    VaiTro,
    MaNhanVien
)
VALUES
(
    'admin',
    '123456',
    N'Quản trị viên',
    1
),
(
    'le_tan',
    '123456',
    N'Lễ tân',
    1
);
GO


/* ============================================================
   PHẦN 42. VIEW THÔNG TIN LỊCH HẸN
   ============================================================ */

CREATE VIEW XemLichHen
AS
SELECT
    LH.MaLichHen,

    BN.MaBenhNhan,
    BN.HoTen AS TenBenhNhan,
    BN.SoDienThoai,

    BS.MaBacSi,
    BS.HoTen AS TenBacSi,

    P.TenPhong,

    G.TenGhe,

    LH.ThoiGianHen,
    LH.LyDoHen,
    LH.TrangThai,
    LH.GhiChu

FROM LichHen LH

INNER JOIN BenhNhan BN
    ON LH.MaBenhNhan = BN.MaBenhNhan

INNER JOIN BacSi BS
    ON LH.MaBacSi = BS.MaBacSi

LEFT JOIN PhongKham P
    ON LH.MaPhong = P.MaPhong

LEFT JOIN GheNhaKhoa G
    ON LH.MaGhe = G.MaGhe;
GO


/* ============================================================
   PHẦN 43. VIEW LỊCH SỬ KHÁM
   ============================================================ */

CREATE VIEW XemLichSuKham
AS
SELECT
    PK.MaPhieuKham,

    BN.MaBenhNhan,
    BN.HoTen AS TenBenhNhan,

    BS.HoTen AS TenBacSi,

    PK.NgayKham,
    PK.LyDoKham,
    PK.ChanDoan,
    PK.KetLuan,
    PK.HuongDieuTri

FROM PhieuKham PK

INNER JOIN BenhNhan BN
    ON PK.MaBenhNhan = BN.MaBenhNhan

INNER JOIN BacSi BS
    ON PK.MaBacSi = BS.MaBacSi;
GO


/* ============================================================
   PHẦN 44. VIEW HÓA ĐƠN
   ============================================================ */

CREATE VIEW XemHoaDon
AS
SELECT
    HD.MaHoaDon,

    BN.MaBenhNhan,
    BN.HoTen AS TenBenhNhan,

    HD.MaPhieuKham,

    HD.NgayLap,

    HD.TongTien,

    HD.GiamGia,

    HD.ThanhTien,

    HD.TrangThai

FROM HoaDon HD

INNER JOIN BenhNhan BN
    ON HD.MaBenhNhan = BN.MaBenhNhan;
GO


/* ============================================================
   PHẦN 45. PROCEDURE TÌM BỆNH NHÂN
   ============================================================ */

CREATE PROCEDURE TimBenhNhan
    @TuKhoa NVARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        MaBenhNhan,
        HoTen,
        NgaySinh,
        GioiTinh,
        SoDienThoai,
        Email,
        DiaChi
    FROM BenhNhan

    WHERE HoTen LIKE N'%' + @TuKhoa + N'%'
       OR SoDienThoai LIKE '%' + @TuKhoa + '%';

END;
GO


/* ============================================================
   PHẦN 46. PROCEDURE XEM LỊCH HẸN THEO NGÀY
   ============================================================ */

CREATE PROCEDURE LayLichHenTheoNgay
    @Ngay DATE
AS
BEGIN

    SET NOCOUNT ON;

    SELECT *
    FROM XemLichHen

    WHERE CAST(ThoiGianHen AS DATE) = @Ngay

    ORDER BY ThoiGianHen;

END;
GO


/* ============================================================
   PHẦN 47. PROCEDURE LẤY LỊCH SỬ KHÁM BỆNH NHÂN
   ============================================================ */

CREATE PROCEDURE LayLichSuKham
    @MaBenhNhan INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT *
    FROM XemLichSuKham

    WHERE MaBenhNhan = @MaBenhNhan

    ORDER BY NgayKham DESC;

END;
GO


/* ============================================================
   PHẦN 48. PROCEDURE CẬP NHẬT TRẠNG THÁI LỊCH HẸN
   ============================================================ */

CREATE PROCEDURE CapNhatTrangThaiLichHen
    @MaLichHen INT,
    @TrangThai NVARCHAR(30)
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE LichHen

    SET TrangThai = @TrangThai

    WHERE MaLichHen = @MaLichHen;

END;
GO


/* ============================================================
   PHẦN 49. PROCEDURE THỐNG KÊ DOANH THU
   ============================================================ */

CREATE PROCEDURE ThongKeDoanhThu
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        COUNT(MaHoaDon) AS SoHoaDon,

        SUM(TongTien) AS TongTien,

        SUM(GiamGia) AS TongGiamGia,

        SUM(ThanhTien) AS DoanhThu

    FROM HoaDon

    WHERE TrangThai = N'Đã thanh toán';

END;
GO


/* ============================================================
   PHẦN 50. INDEX
   ============================================================ */

CREATE INDEX IX_BenhNhan_HoTen
ON BenhNhan(HoTen);
GO

CREATE INDEX IX_BenhNhan_SoDienThoai
ON BenhNhan(SoDienThoai);
GO

CREATE INDEX IX_LichHen_ThoiGian
ON LichHen(ThoiGianHen);
GO

CREATE INDEX IX_LichHen_BenhNhan
ON LichHen(MaBenhNhan);
GO

CREATE INDEX IX_LichHen_BacSi
ON LichHen(MaBacSi);
GO

CREATE INDEX IX_PhieuKham_BenhNhan
ON PhieuKham(MaBenhNhan);
GO

CREATE INDEX IX_PhieuKham_NgayKham
ON PhieuKham(NgayKham);
GO

CREATE INDEX IX_DieuTri_MaPhieuKham
ON DieuTri(MaPhieuKham);
GO

CREATE INDEX IX_HoaDon_BenhNhan
ON HoaDon(MaBenhNhan);
GO

CREATE INDEX IX_HoaDon_NgayLap
ON HoaDon(NgayLap);
GO

CREATE INDEX IX_ThanhToan_MaHoaDon
ON ThanhToan(MaHoaDon);
GO


/* ============================================================
   PHẦN 51. CÁC CÂU LỆNH KIỂM TRA
   ============================================================ */

-- Xem bệnh nhân
SELECT *
FROM BenhNhan;
GO


-- Xem bác sĩ
SELECT *
FROM BacSi;
GO


-- Xem lịch hẹn
SELECT *
FROM XemLichHen
ORDER BY ThoiGianHen;
GO


-- Xem lịch sử khám
SELECT *
FROM XemLichSuKham
ORDER BY NgayKham DESC;
GO


-- Xem hóa đơn
SELECT *
FROM XemHoaDon;
GO


-- Tìm bệnh nhân
EXEC TimBenhNhan
    @TuKhoa = N'Khoa';
GO


-- Lấy lịch hẹn ngày 01/09/2026
EXEC LayLichHenTheoNgay
    @Ngay = '2026-09-01';
GO


-- Xem lịch sử khám bệnh nhân số 1
EXEC LayLichSuKham
    @MaBenhNhan = 1;
GO


-- Thống kê doanh thu
EXEC ThongKeDoanhThu;
GO


/* ============================================================
   KẾT THÚC HỆ THỐNG
   ============================================================ */
```
