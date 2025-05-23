from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.graphics.shapes import Drawing
from reportlab.graphics.charts.piecharts import Pie
import os
import logging

logger = logging.getLogger(__name__)

def generate_pdf_report(detection, username, output_path):
    try:
        doc = SimpleDocTemplate(output_path, pagesize=A4)
        styles = getSampleStyleSheet()
        elements = []

        # 标题
        title_style = ParagraphStyle(
            'Title',
            parent=styles['Heading1'],
            fontSize=18,
            spaceAfter=20,
            textColor=colors.darkbrown
        )
        elements.append(Paragraph("匠知 - 古建筑检测报告", title_style))

        # 用户信息
        elements.append(Paragraph(f"用户: {username}", styles['Normal']))
        elements.append(Paragraph(f"检测 ID: {detection.id}", styles['Normal']))
        elements.append(Paragraph(f"时间: {detection.timestamp.isoformat()}", styles['Normal']))
        elements.append(Spacer(1, 0.2 * inch))

        # 检测概述
        elements.append(Paragraph("检测概述", styles['Heading2']))
        overview = f"""
        <b>图片</b>: {detection.image_url}<br/>
        <b>材料损失</b>: {'是' if detection.material_lost else '否'}<br/>
        <b>严重程度</b>: {detection.severity}<br/>
        <b>缺陷摘要</b>: {detection.summary}
        """
        elements.append(Paragraph(overview, styles['Normal']))
        elements.append(Spacer(1, 0.2 * inch))

        # 检测图片
        image_path = os.path.join(current_app.config['UPLOAD_FOLDER'], os.path.basename(detection.image_url))
        if os.path.exists(image_path):
            img = Image(image_path, width=3 * inch, height=2 * inch)
            elements.append(img)
        if detection.annotated_image_url:
            annotated_path = os.path.join(current_app.config['UPLOAD_FOLDER'], os.path.basename(detection.annotated_image_url))
            if os.path.exists(annotated_path):
                elements.append(Paragraph("标注图片", styles['Heading3']))
                img = Image(annotated_path, width=3 * inch, height=2 * inch)
                elements.append(img)
        elements.append(Spacer(1, 0.2 * inch))

        # 缺陷详情
        elements.append(Paragraph("缺陷详情", styles['Heading2']))
        coordinates = eval(detection.coordinates) if detection.coordinates else []
        if coordinates:
            data = [['类型', '坐标 (x, y)', '置信度']]
            for coord in coordinates:
                data.append([
                    coord['class'],
                    f"({coord['x']:.0f}, {coord['y']:.0f})",
                    f"{coord['confidence']:.2f}"
                ])
            table = Table(data)
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 12),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ]))
            elements.append(table)
        else:
            elements.append(Paragraph("未检测到缺陷", styles['Normal']))
        elements.append(Spacer(1, 0.2 * inch))

        # 修复建议
        elements.append(Paragraph("修复建议", styles['Heading2']))
        suggestions = {
            '严重': '立即修复，联系专业文物修复团队，使用高强度修复材料。',
            '中度': '计划短期内修复，定期检查以防止恶化。',
            '轻微': '定期维护，保持环境干燥，避免进一步损害。',
            '无': '无需立即修复，建议持续监测。'
        }
        elements.append(Paragraph(suggestions.get(detection.severity, '根据检测结果定制修复方案'), styles['Normal']))
        elements.append(Spacer(1, 0.2 * inch))

        # 文化价值
        elements.append(Paragraph("文化价值评估", styles['Heading2']))
        elements.append(Paragraph(
            "该古建筑具有重要历史和文化价值，修复需遵循文物保护原则，确保材料和工艺符合传统标准。",
            styles['Normal']
        ))
        elements.append(Spacer(1, 0.2 * inch))

        # 严重程度分布（饼图）
        elements.append(Paragraph("严重程度分布", styles['Heading2']))
        d = Drawing(200, 100)
        pc = Pie()
        pc.width = pc.height = 100
        pc.data = [1]  # 示例数据，实际需从统计 API 获取
        pc.labels = [detection.severity]
        pc.slices.strokeColor = colors.white
        pc.slices[0].fillColor = colors.red if detection.severity == '严重' else colors.yellow
        d.add(pc)
        elements.append(d)

        doc.build(elements)
        logger.info(f"生成 PDF 报告: {output_path}")
    except Exception as e:
        logger.error(f"生成 PDF 报告失败: {str(e)}")
        raise