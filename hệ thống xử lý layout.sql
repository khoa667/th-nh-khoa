/* =========================================================
   1. XÓA DATABASE CŨ NẾU ĐÃ TỒN TẠI
   ========================================================= */

USE master;
GO

IF DB_ID(N'HeThongXuLyLayout') IS NOT NULL
BEGIN
    ALTER DATABASE HeThongXuLyLayout
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE HeThongXuLyLayout;
END;
GO


/* =========================================================
   2. TẠO DATABASE
   ========================================================= */

CREATE DATABASE HeThongXuLyLayout;
GO

USE HeThongXuLyLayout;
GO


/* =========================================================
   3. TẠO BẢNG LOẠI TÀI LIỆU
   ========================================================= */

CREATE TABLE LOAI_TAI_LIEU
(
    MaLoaiTaiLieu INT IDENTITY(1,1) PRIMARY KEY,

    TenLoaiTaiLieu NVARCHAR(100) NOT NULL,

    MoTa NVARCHAR(500)
);
GO


/* =========================================================
   4. TẠO BẢNG TÀI LIỆU
   ========================================================= */

CREATE TABLE TAI_LIEU
(
    MaTaiLieu INT IDENTITY(1,1) PRIMARY KEY,

    TenTaiLieu NVARCHAR(200) NOT NULL,

    MaLoaiTaiLieu INT NOT NULL,

    DuongDanAnh NVARCHAR(500),

    DinhDangAnh NVARCHAR(20),

    ChieuRong INT,

    ChieuCao INT,

    NgayTao DATETIME DEFAULT GETDATE(),

    TrangThai NVARCHAR(50) DEFAULT N'Mới',

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_TAI_LIEU_LOAI
    FOREIGN KEY (MaLoaiTaiLieu)
    REFERENCES LOAI_TAI_LIEU(MaLoaiTaiLieu),

    CONSTRAINT CK_TAI_LIEU_KICH_THUOC
    CHECK (ChieuRong > 0 AND ChieuCao > 0)
);
GO


/* =========================================================
   5. TẠO BẢNG TRANG TÀI LIỆU
   ========================================================= */

CREATE TABLE TRANG_TAI_LIEU
(
    MaTrang INT IDENTITY(1,1) PRIMARY KEY,

    MaTaiLieu INT NOT NULL,

    SoTrang INT NOT NULL,

    DuongDanAnh NVARCHAR(500),

    ChieuRong INT,

    ChieuCao INT,

    GocXoay DECIMAL(6,2) DEFAULT 0,

    GocNghieng DECIMAL(6,2) DEFAULT 0,

    DaSuaPhoiCanh BIT DEFAULT 0,

    DaKhuiNhieu BIT DEFAULT 0,

    TrangThai NVARCHAR(50) DEFAULT N'Chưa xử lý',

    CONSTRAINT FK_TRANG_TAI_LIEU
    FOREIGN KEY (MaTaiLieu)
    REFERENCES TAI_LIEU(MaTaiLieu),

    CONSTRAINT CK_TRANG_SO_TRANG
    CHECK (SoTrang > 0),

    CONSTRAINT CK_TRANG_KICH_THUOC
    CHECK (ChieuRong > 0 AND ChieuCao > 0)
);
GO


/* =========================================================
   6. TẠO BẢNG LOẠI LAYOUT
   ========================================================= */

CREATE TABLE LOAI_LAYOUT
(
    MaLoaiLayout INT IDENTITY(1,1) PRIMARY KEY,

    TenLoaiLayout NVARCHAR(100) NOT NULL,

    MoTa NVARCHAR(500)
);
GO


/* =========================================================
   7. THÊM LOẠI LAYOUT
   ========================================================= */

INSERT INTO LOAI_LAYOUT
(
    TenLoaiLayout,
    MoTa
)
VALUES
(N'Tiêu đề', N'Vùng tiêu đề của tài liệu'),
(N'Văn bản', N'Vùng chứa nội dung văn bản'),
(N'Hình ảnh', N'Vùng chứa hình ảnh'),
(N'Bảng', N'Vùng chứa bảng dữ liệu'),
(N'Danh sách', N'Vùng chứa danh sách'),
(N'Đầu trang', N'Vùng đầu trang'),
(N'Chân trang', N'Vùng chân trang'),
(N'Chú thích', N'Vùng chú thích'),
(N'Công thức', N'Vùng chứa công thức');
GO


/* =========================================================
   8. TẠO BẢNG VÙNG LAYOUT
   ========================================================= */

CREATE TABLE VUNG_LAYOUT
(
    MaVung INT IDENTITY(1,1) PRIMARY KEY,

    MaTrang INT NOT NULL,

    MaLoaiLayout INT NOT NULL,

    ToaDoX1 INT NOT NULL,

    ToaDoY1 INT NOT NULL,

    ToaDoX2 INT NOT NULL,

    ToaDoY2 INT NOT NULL,

    DoTinCay DECIMAL(5,4),

    DienTich AS
    (
        (ToaDoX2 - ToaDoX1)
        *
        (ToaDoY2 - ToaDoY1)
    ),

    ThuTuPhatHien INT,

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_VUNG_TRANG
    FOREIGN KEY (MaTrang)
    REFERENCES TRANG_TAI_LIEU(MaTrang),

    CONSTRAINT FK_VUNG_LOAI
    FOREIGN KEY (MaLoaiLayout)
    REFERENCES LOAI_LAYOUT(MaLoaiLayout),

    CONSTRAINT CK_VUNG_TOA_DO
    CHECK
    (
        ToaDoX2 > ToaDoX1
        AND
        ToaDoY2 > ToaDoY1
    ),

    CONSTRAINT CK_VUNG_DO_TIN_CAY
    CHECK
    (
        DoTinCay IS NULL
        OR
        (DoTinCay >= 0 AND DoTinCay <= 1)
    )
);
GO


/* =========================================================
   9. TẠO BẢNG KẾT QUẢ OCR
   ========================================================= */

CREATE TABLE KET_QUA_OCR
(
    MaOCR INT IDENTITY(1,1) PRIMARY KEY,

    MaVung INT NOT NULL,

    NoiDung NVARCHAR(MAX),

    DoTinCay DECIMAL(5,4),

    NgonNgu NVARCHAR(50),

    NgayXuLy DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_OCR_VUNG
    FOREIGN KEY (MaVung)
    REFERENCES VUNG_LAYOUT(MaVung),

    CONSTRAINT CK_OCR_DO_TIN_CAY
    CHECK
    (
        DoTinCay IS NULL
        OR
        (DoTinCay >= 0 AND DoTinCay <= 1)
    )
);
GO


/* =========================================================
   10. TẠO BẢNG THỨ TỰ ĐỌC
   ========================================================= */

CREATE TABLE THU_TU_DOC
(
    MaThuTu INT IDENTITY(1,1) PRIMARY KEY,

    MaTrang INT NOT NULL,

    MaVung INT NOT NULL,

    ThuTuDoc INT NOT NULL,

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_THUTU_TRANG
    FOREIGN KEY (MaTrang)
    REFERENCES TRANG_TAI_LIEU(MaTrang),

    CONSTRAINT FK_THUTU_VUNG
    FOREIGN KEY (MaVung)
    REFERENCES VUNG_LAYOUT(MaVung),

    CONSTRAINT CK_THUTU_DOC
    CHECK (ThuTuDoc > 0)
);
GO


/* =========================================================
   11. TẠO BẢNG BẢNG TÀI LIỆU
   ========================================================= */

CREATE TABLE BANG_TAI_LIEU
(
    MaBang INT IDENTITY(1,1) PRIMARY KEY,

    MaVung INT NOT NULL,

    SoDong INT,

    SoCot INT,

    DoTinCay DECIMAL(5,4),

    GhiChu NVARCHAR(500),

    CONSTRAINT FK_BANG_VUNG
    FOREIGN KEY (MaVung)
    REFERENCES VUNG_LAYOUT(MaVung),

    CONSTRAINT CK_BANG_DONG_COT
    CHECK
    (
        SoDong > 0
        AND
        SoCot > 0
    ),

    CONSTRAINT CK_BANG_DO_TIN_CAY
    CHECK
    (
        DoTinCay IS NULL
        OR
        (DoTinCay >= 0 AND DoTinCay <= 1)
    )
);
GO


/* =========================================================
   12. TẠO BẢNG Ô BẢNG
   ========================================================= */

CREATE TABLE O_BANG
(
    MaOBang INT IDENTITY(1,1) PRIMARY KEY,

    MaBang INT NOT NULL,

    SoDong INT NOT NULL,

    SoCot INT NOT NULL,

    ToaDoX1 INT,

    ToaDoY1 INT,

    ToaDoX2 INT,

    ToaDoY2 INT,

    NoiDung NVARCHAR(MAX),

    DoTinCay DECIMAL(5,4),

    CONSTRAINT FK_O_BANG
    FOREIGN KEY (MaBang)
    REFERENCES BANG_TAI_LIEU(MaBang),

    CONSTRAINT CK_O_BANG_DONG
    CHECK (SoDong > 0),

    CONSTRAINT CK_O_BANG_COT
    CHECK (SoCot > 0),

    CONSTRAINT CK_O_BANG_DO_TIN_CAY
    CHECK
    (
        DoTinCay IS NULL
        OR
        (DoTinCay >= 0 AND DoTinCay <= 1)
    )
);
GO


/* =========================================================
   13. THÊM LOẠI TÀI LIỆU
   ========================================================= */

INSERT INTO LOAI_TAI_LIEU
(
    TenLoaiTaiLieu,
    MoTa
)
VALUES
(N'Giáo trình', N'Tài liệu giáo dục'),
(N'Hóa đơn', N'Hóa đơn mua bán'),
(N'Văn bản hành chính', N'Tài liệu hành chính'),
(N'Sách', N'Tài liệu sách'),
(N'Báo', N'Tài liệu báo chí'),
(N'Biểu mẫu', N'Tài liệu biểu mẫu');
GO


/* =========================================================
   14. THÊM TÀI LIỆU
   ========================================================= */

INSERT INTO TAI_LIEU
(
    TenTaiLieu,
    MaLoaiTaiLieu,
    DuongDanAnh,
    DinhDangAnh,
    ChieuRong,
    ChieuCao,
    TrangThai,
    GhiChu
)
VALUES
(
    N'Tài liệu Layout mẫu',
    1,
    N'D:\Anh\tailieu.jpg',
    N'JPG',
    1920,
    1080,
    N'Đã xử lý',
    N'Tài liệu dùng để kiểm thử hệ thống'
);
GO


/* =========================================================
   15. THÊM TRANG TÀI LIỆU
   ========================================================= */

INSERT INTO TRANG_TAI_LIEU
(
    MaTaiLieu,
    SoTrang,
    DuongDanAnh,
    ChieuRong,
    ChieuCao,
    GocXoay,
    GocNghieng,
    DaSuaPhoiCanh,
    DaKhuiNhieu,
    TrangThai
)
VALUES
(
    1,
    1,
    N'D:\Anh\tailieu_trang1.jpg',
    1920,
    1080,
    0,
    1.20,
    1,
    1,
    N'Đã xử lý'
);
GO


/* =========================================================
   16. THÊM CÁC VÙNG LAYOUT
   ========================================================= */

INSERT INTO VUNG_LAYOUT
(
    MaTrang,
    MaLoaiLayout,
    ToaDoX1,
    ToaDoY1,
    ToaDoX2,
    ToaDoY2,
    DoTinCay,
    ThuTuPhatHien,
    GhiChu
)
VALUES

-- Vùng tiêu đề
(
    1,
    1,
    100,
    50,
    900,
    150,
    0.9800,
    1,
    N'Vùng tiêu đề'
),

-- Vùng văn bản
(
    1,
    2,
    100,
    180,
    900,
    400,
    0.9600,
    2,
    N'Vùng văn bản'
),

-- Vùng hình ảnh
(
    1,
    3,
    100,
    430,
    700,
    750,
    0.9500,
    3,
    N'Vùng hình ảnh'
),

-- Vùng bảng
(
    1,
    4,
    100,
    780,
    1000,
    1000,
    0.9700,
    4,
    N'Vùng bảng dữ liệu'
);
GO


/* =========================================================
   17. THÊM KẾT QUẢ OCR
   ========================================================= */

INSERT INTO KET_QUA_OCR
(
    MaVung,
    NoiDung,
    DoTinCay,
    NgonNgu
)
VALUES
(
    1,
    N'HỆ THỐNG XỬ LÝ LAYOUT ẢNH CHỤP VĂN BẢN',
    0.9900,
    N'Tiếng Việt'
),

(
    2,
    N'Hệ thống có nhiệm vụ phân tích bố cục tài liệu.',
    0.9600,
    N'Tiếng Việt'
);
GO


/* =========================================================
   18. THÊM THỨ TỰ ĐỌC
   ========================================================= */

INSERT INTO THU_TU_DOC
(
    MaTrang,
    MaVung,
    ThuTuDoc,
    GhiChu
)
VALUES
(1, 1, 1, N'Đọc tiêu đề trước'),

(1, 2, 2, N'Đọc nội dung văn bản'),

(1, 3, 3, N'Đọc hình ảnh'),

(1, 4, 4, N'Đọc bảng');
GO


/* =========================================================
   19. THÊM THÔNG TIN BẢNG
   ========================================================= */

INSERT INTO BANG_TAI_LIEU
(
    MaVung,
    SoDong,
    SoCot,
    DoTinCay,
    GhiChu
)
VALUES
(
    4,
    3,
    3,
    0.9700,
    N'Bảng mẫu gồm 3 dòng và 3 cột'
);
GO


/* =========================================================
   20. THÊM CÁC Ô BẢNG
   ========================================================= */

INSERT INTO O_BANG
(
    MaBang,
    SoDong,
    SoCot,
    ToaDoX1,
    ToaDoY1,
    ToaDoX2,
    ToaDoY2,
    NoiDung,
    DoTinCay
)
VALUES

(1, 1, 1, 100, 780, 400, 850, N'Mã', 0.98),

(1, 1, 2, 400, 780, 700, 850, N'Tên', 0.98),

(1, 1, 3, 700, 780, 1000, 850, N'Điểm', 0.98),

(1, 2, 1, 100, 850, 400, 920, N'01', 0.97),

(1, 2, 2, 400, 850, 700, 920, N'Nguyễn Văn An', 0.96),

(1, 2, 3, 700, 850, 1000, 920, N'9', 0.99),

(1, 3, 1, 100, 920, 400, 1000, N'02', 0.97),

(1, 3, 2, 400, 920, 700, 1000, N'Trần Văn Bình', 0.95),

(1, 3, 3, 700, 920, 1000, 1000, N'8', 0.99);
GO


/* =========================================================
   21. TRUY VẤN TOÀN BỘ LOẠI LAYOUT
   ========================================================= */

SELECT *
FROM LOAI_LAYOUT;
GO


/* =========================================================
   22. TRUY VẤN TOÀN BỘ TÀI LIỆU
   ========================================================= */

SELECT *
FROM TAI_LIEU;
GO


/* =========================================================
   23. TRUY VẤN TOÀN BỘ VÙNG LAYOUT
   ========================================================= */

SELECT
    V.MaVung,
    L.TenLoaiLayout,
    V.ToaDoX1,
    V.ToaDoY1,
    V.ToaDoX2,
    V.ToaDoY2,
    V.DienTich,
    V.DoTinCay
FROM VUNG_LAYOUT AS V
JOIN LOAI_LAYOUT AS L
    ON V.MaLoaiLayout = L.MaLoaiLayout;
GO


/* =========================================================
   24. TÌM VÙNG CÓ ĐỘ TIN CẬY CAO
   ========================================================= */

SELECT
    V.MaVung,
    L.TenLoaiLayout,
    V.DoTinCay
FROM VUNG_LAYOUT AS V
JOIN LOAI_LAYOUT AS L
    ON V.MaLoaiLayout = L.MaLoaiLayout
WHERE V.DoTinCay >= 0.95
ORDER BY V.DoTinCay DESC;
GO


/* =========================================================
   25. XEM KẾT QUẢ OCR
   ========================================================= */

SELECT
    O.MaOCR,
    V.MaVung,
    L.TenLoaiLayout,
    O.NoiDung,
    O.DoTinCay,
    O.NgonNgu,
    O.NgayXuLy
FROM KET_QUA_OCR AS O
JOIN VUNG_LAYOUT AS V
    ON O.MaVung = V.MaVung
JOIN LOAI_LAYOUT AS L
    ON V.MaLoaiLayout = L.MaLoaiLayout;
GO


/* =========================================================
   26. XEM THỨ TỰ ĐỌC
   ========================================================= */

SELECT
    T.MaTrang,
    T.MaVung,
    L.TenLoaiLayout,
    T.ThuTuDoc
FROM THU_TU_DOC AS T
JOIN VUNG_LAYOUT AS V
    ON T.MaVung = V.MaVung
JOIN LOAI_LAYOUT AS L
    ON V.MaLoaiLayout = L.MaLoaiLayout
ORDER BY T.ThuTuDoc;
GO


/* =========================================================
   27. XEM BẢNG VÀ CÁC Ô
   ========================================================= */

SELECT
    B.MaBang,
    B.SoDong,
    B.SoCot,
    O.SoDong AS Dong,
    O.SoCot AS Cot,
    O.NoiDung,
    O.DoTinCay
FROM BANG_TAI_LIEU AS B
JOIN O_BANG AS O
    ON B.MaBang = O.MaBang
ORDER BY
    O.SoDong,
    O.SoCot;
GO


/* =========================================================
   28. TẠO VIEW XEM TOÀN BỘ LAYOUT
   ========================================================= */

CREATE VIEW V_XEM_LAYOUT
AS
SELECT
    TL.MaTaiLieu,
    TL.TenTaiLieu,

    P.MaTrang,
    P.SoTrang,

    V.MaVung,

    L.TenLoaiLayout,

    V.ToaDoX1,
    V.ToaDoY1,
    V.ToaDoX2,
    V.ToaDoY2,

    V.DienTich,

    V.DoTinCay,

    V.ThuTuPhatHien

FROM TAI_LIEU AS TL

JOIN TRANG_TAI_LIEU AS P
    ON TL.MaTaiLieu = P.MaTaiLieu

JOIN VUNG_LAYOUT AS V
    ON P.MaTrang = V.MaTrang

JOIN LOAI_LAYOUT AS L
    ON V.MaLoaiLayout = L.MaLoaiLayout;
GO


/* =========================================================
   29. SỬ DỤNG VIEW
   ========================================================= */

SELECT *
FROM V_XEM_LAYOUT
ORDER BY
    MaTaiLieu,
    SoTrang,
    ToaDoY1,
    ToaDoX1;
GO


/* =========================================================
   30. PROCEDURE TÌM LAYOUT THEO TRANG
   ========================================================= */

CREATE PROCEDURE TimLayoutTheoTrang
    @MaTrang INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        V.MaVung,

        L.TenLoaiLayout,

        V.ToaDoX1,
        V.ToaDoY1,

        V.ToaDoX2,
        V.ToaDoY2,

        V.DienTich,

        V.DoTinCay,

        V.ThuTuPhatHien

    FROM VUNG_LAYOUT AS V

    JOIN LOAI_LAYOUT AS L
        ON V.MaLoaiLayout = L.MaLoaiLayout

    WHERE V.MaTrang = @MaTrang

    ORDER BY
        V.ToaDoY1,
        V.ToaDoX1;

END;
GO


/* =========================================================
   31. CHẠY PROCEDURE
   ========================================================= */

EXEC TimLayoutTheoTrang @MaTrang = 1;
GO


/* =========================================================
   32. PROCEDURE TÌM KIẾM OCR
   ========================================================= */

CREATE PROCEDURE TimNoiDungOCR
    @TuKhoa NVARCHAR(200)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        TL.TenTaiLieu,

        P.SoTrang,

        V.MaVung,

        L.TenLoaiLayout,

        O.NoiDung,

        O.DoTinCay,

        O.NgonNgu

    FROM KET_QUA_OCR AS O

    JOIN VUNG_LAYOUT AS V
        ON O.MaVung = V.MaVung

    JOIN LOAI_LAYOUT AS L
        ON V.MaLoaiLayout = L.MaLoaiLayout

    JOIN TRANG_TAI_LIEU AS P
        ON V.MaTrang = P.MaTrang

    JOIN TAI_LIEU AS TL
        ON P.MaTaiLieu = TL.MaTaiLieu

    WHERE O.NoiDung LIKE N'%' + @TuKhoa + N'%';

END;
GO


/* =========================================================
   33. CHẠY TÌM KIẾM OCR
   ========================================================= */

EXEC TimNoiDungOCR
    @TuKhoa = N'HỆ THỐNG';
GO


/* =========================================================
   34. TẠO INDEX
   ========================================================= */

CREATE INDEX IX_VUNG_TRANG
ON VUNG_LAYOUT(MaTrang);
GO

CREATE INDEX IX_VUNG_LOAI
ON VUNG_LAYOUT(MaLoaiLayout);
GO

CREATE INDEX IX_OCR_VUNG
ON KET_QUA_OCR(MaVung);
GO

CREATE INDEX IX_THUTU_TRANG
ON THU_TU_DOC(MaTrang, ThuTuDoc);
GO

CREATE INDEX IX_TAI_LIEU_LOAI
ON TAI_LIEU(MaLoaiTaiLieu);
GO


/* =========================================================
   35. KIỂM TRA CUỐI CÙNG
   ========================================================= */

SELECT
    'LOAI_TAI_LIEU' AS TenBang,
    COUNT(*) AS SoLuong
FROM LOAI_TAI_LIEU

UNION ALL

SELECT
    'TAI_LIEU',
    COUNT(*)
FROM TAI_LIEU

UNION ALL

SELECT
    'TRANG_TAI_LIEU',
    COUNT(*)
FROM TRANG_TAI_LIEU

UNION ALL

SELECT
    'LOAI_LAYOUT',
    COUNT(*)
FROM LOAI_LAYOUT

UNION ALL

SELECT
    'VUNG_LAYOUT',
    COUNT(*)
FROM VUNG_LAYOUT

UNION ALL

SELECT
    'KET_QUA_OCR',
    COUNT(*)
FROM KET_QUA_OCR

UNION ALL

SELECT
    'THU_TU_DOC',
    COUNT(*)
FROM THU_TU_DOC

UNION ALL

SELECT
    'BANG_TAI_LIEU',
    COUNT(*)
FROM BANG_TAI_LIEU

UNION ALL

SELECT
    'O_BANG',
    COUNT(*)
FROM O_BANG;
GO