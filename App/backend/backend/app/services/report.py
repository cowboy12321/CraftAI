from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import os
import logging
from flask import current_app

logger = logging.getLogger(__name__)

def register_chinese_font():
    """注册中文字体，防止乱码"""
    font_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'fonts', 'simsun.ttc')
    # 如果没有字体文件，请务必放入 backend/fonts/simsun.ttc
    if os.path.exists(font_path):
        pdfmetrics.registerFont(TTFont('SimSun', font_path))
        return 'SimSun'
    else:
        logger.warning("未找到中文字体文件，中文将无法显示！")
        return 'Helvetica' 

def generate_pdf_report(detection, username, output_path):
    try:
        font_name = register_chinese_font()
        doc = SimpleDocTemplate(output_path, pagesize=A4)
        styles = getSampleStyleSheet()
        
        # 定义支持中文的样式
        normal_style = ParagraphStyle(
            'ChineseNormal',
            parent=styles['Normal'],
            fontName=font_name,
            fontSize=12,
            leading=20
        )
        title_style = ParagraphStyle(
            'ChineseTitle',
            parent=styles['Heading1'],
            fontName=font_name,
            fontSize=24,
            spaceAfter=30,
            alignment=1 # 居中
        )
        heading_style = ParagraphStyle(
            'ChineseHeading',
            parent=styles['Heading2'],
            fontName=font_name,
            fontSize=16,
            spaceBefore=15,
            spaceAfter=10,
            textColor=colors.HexColor('#8B4513')
        )

        elements = []

        # 1. 标题
        elements.append(Paragraph("匠知 — 古建筑智能检测报告", title_style))
        elements.append(Spacer(1, 0.2 * inch))

        # 2. 基础信息表
        data_info = [
            ['检测编号', str(detection.id), '检测用户', username],
            ['检测时间', detection.timestamp.strftime('%Y-%m-%d %H:%M'), '严重程度', detection.severity]
        ]
        t_info = Table(data_info, colWidths=[1.5*inch, 2.5*inch, 1.5*inch, 2*inch])
        t_info.setStyle(TableStyle([
            ('FONTNAME', (0, 0), (-1, -1), font_name),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('BACKGROUND', (0, 0), (0, -1), colors.beige),
            ('BACKGROUND', (2, 0), (2, -1), colors.beige),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ]))
        elements.append(t_info)
        elements.append(Spacer(1, 0.3 * inch))

        # 3. 智能分析摘要 (GPT内容)
        elements.append(Paragraph("智能分析摘要", heading_style))
        # 处理换行符，确保段落正常显示
        summary_text = detection.summary.replace('\n', '<br/>') if detection.summary else "暂无分析摘要"
        elements.append(Paragraph(summary_text, normal_style))
        elements.append(Spacer(1, 0.2 * inch))

        # 4. 图像证据
        elements.append(Paragraph("图像证据", heading_style))
        
        # 计算图片路径 (兼容 Docker 和 本地路径)
        img_filename = os.path.basename(detection.image_url)
        img_path = os.path.join(current_app.config['UPLOAD_FOLDER'], img_filename)
        
        imgs_row = []
        if os.path.exists(img_path):
            img = Image(img_path, width=3*inch, height=2.25*inch)
            imgs_row.append(img)
        
        if detection.annotated_image_url:
            anno_filename = os.path.basename(detection.annotated_image_url)
            anno_path = os.path.join(current_app.config['UPLOAD_FOLDER'], anno_filename)
            if os.path.exists(anno_path):
                img_anno = Image(anno_path, width=3*inch, height=2.25*inch)
                imgs_row.append(img_anno)
        
        if imgs_row:
            t_imgs = Table([imgs_row], colWidths=[3.5*inch]*len(imgs_row))
            elements.append(t_imgs)
            elements.append(Table([['原始图像', 'AI标注图像']], colWidths=[3.5*inch]*len(imgs_row), style=TableStyle([
                ('FONTNAME', (0,0), (-1,-1), font_name),
                ('ALIGN', (0,0), (-1,-1), 'CENTER')
            ])))

        doc.build(elements)
        logger.info(f"PDF报告生成成功: {output_path}")

    except Exception as e:
        logger.error(f"生成PDF报告失败: {str(e)}", exc_info=True)
        raise