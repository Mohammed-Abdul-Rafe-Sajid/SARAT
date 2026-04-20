#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF Report Generation for SARAT v3
Creates multi-page bulletin-style reports with probability maps
"""

import os
from datetime import datetime
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Image, Paragraph, Spacer, PageBreak,
    Table, TableStyle, KeepTogether
)
from reportlab.lib import colors


def generate_pdf_report(output_path, case_id, intervals, png_prefix="seeding", case_info=None):
    """
    Generate a multi-page SARAT report PDF
    
    Creates a professional bulletin-style report with:
    - Title page
    - Interval-wise probability maps
    - Metadata and statistics
    
    Parameters
    ----------
    output_path : str
        Directory where PDF will be saved
    case_id : str or int
        Case identifier (e.g., "6687")
    intervals : list of tuples
        List of (start_hour, end_hour) tuples
    png_prefix : str
        Prefix for PNG image files (e.g., "seeding")
    case_info : dict, optional
        Additional case metadata (num_trajectories, grid_size, etc.)
    
    Returns
    -------
    str
        Path to generated PDF
    """
    
    pdf_filename = f"sarat_report_{case_id}.pdf"
    pdf_path = os.path.join(output_path, pdf_filename)
    
    # Create document
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=letter,
        rightMargin=0.5*inch,
        leftMargin=0.5*inch,
        topMargin=0.75*inch,
        bottomMargin=0.75*inch
    )
    
    # Story (list of elements to add to PDF)
    story = []
    
    # Get styles
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#1e3c72'),
        spaceAfter=30,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.HexColor('#2a5298'),
        spaceAfter=12,
        spaceBefore=12,
        fontName='Helvetica-Bold'
    )
    
    metadata_style = ParagraphStyle(
        'Metadata',
        parent=styles['Normal'],
        fontSize=9,
        textColor=colors.HexColor('#666666'),
        spaceAfter=6
    )
    
    # ===== TITLE PAGE =====
    story.append(Spacer(1, 0.5*inch))
    
    # Main title
    story.append(Paragraph(
        "🔍 SARAT Search and Rescue Analysis",
        title_style
    ))
    
    # Subtitle
    story.append(Paragraph(
        f"Case #{case_id} Probability Report",
        styles['Heading2']
    ))
    
    story.append(Spacer(1, 0.3*inch))
    
    # Report metadata
    metadata = [
        f"<b>Generated:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"<b>Case ID:</b> {case_id}",
        f"<b>Total Intervals:</b> {len(intervals)}",
        f"<b>Time Coverage:</b> {intervals[0][0]} - {intervals[-1][1]} hours",
    ]
    
    if case_info:
        if 'num_trajectories' in case_info:
            metadata.append(f"<b>Trajectories Analyzed:</b> {case_info['num_trajectories']}")
        if 'grid_size' in case_info:
            metadata.append(f"<b>Grid Resolution:</b> {case_info['grid_size']}°")
        if 'description' in case_info:
            metadata.append(f"<b>Description:</b> {case_info['description']}")
    
    for meta in metadata:
        story.append(Paragraph(meta, metadata_style))
    
    story.append(Spacer(1, 0.2*inch))
    
    # Instructions
    instructions = (
        "This report contains probability distribution maps for each time interval. "
        "Each map shows the search region (convex hull) enclosing high-probability areas. "
        "Darker colors indicate higher probability of containment."
    )
    story.append(Paragraph(instructions, styles['Normal']))
    
    story.append(PageBreak())
    
    # ===== INTERVAL PAGES =====
    for idx, (start_hour, end_hour) in enumerate(intervals):
        interval_label = f"{start_hour:03d}-{end_hour:03d}"
        
        # Heading
        story.append(Paragraph(
            f"Interval {idx + 1}: Hours {start_hour}-{end_hour}",
            heading_style
        ))
        
        story.append(Spacer(1, 0.1*inch))
        
        # Look for PNG image
        png_patterns = [
            f"{png_prefix}_{start_hour}_{end_hour}.png",
            f"{png_prefix}_{interval_label}.png",
            f"seeding_{idx}.png",
        ]
        
        img_path = None
        for pattern in png_patterns:
            full_path = os.path.join(output_path, pattern)
            if os.path.exists(full_path):
                img_path = full_path
                break
        
        if img_path:
            try:
                # Add image with max width of 6 inches
                img = Image(img_path, width=6*inch, height=4*inch)
                story.append(img)
                story.append(Spacer(1, 0.1*inch))
                story.append(Paragraph(
                    f"<i>Figure {idx+1}: Probability distribution for hours {start_hour}-{end_hour}</i>",
                    styles['Normal']
                ))
            except Exception as e:
                story.append(Paragraph(
                    f"<font color='red'>⚠️ Error loading image: {str(e)}</font>",
                    styles['Normal']
                ))
        else:
            story.append(Paragraph(
                f"<font color='orange'>⚠️ PNG file not found for interval {start_hour}-{end_hour}</font>",
                styles['Normal']
            ))
        
        story.append(Spacer(1, 0.15*inch))
        
        # Add interval metadata
        interval_info = f"<b>Interval:</b> {start_hour}-{end_hour} hours | <b>Duration:</b> {end_hour - start_hour} hours"
        story.append(Paragraph(interval_info, metadata_style))
        
        # Page break (except after last interval)
        if idx < len(intervals) - 1:
            story.append(PageBreak())
    
    # ===== BUILD PDF =====
    try:
        doc.build(story)
        print(f"\n✓ PDF Report generated: {pdf_path}")
        print(f"  Total pages: {len(intervals) + 2} (title + {len(intervals)} intervals)")
        return pdf_path
    
    except Exception as e:
        print(f"✗ Error generating PDF: {e}")
        return None


def generate_summary_stats(prob_grids, intervals):
    """
    Generate summary statistics for the report
    
    Parameters
    ----------
    prob_grids : list of np.ndarray
        Probability grids for each interval
    intervals : list of tuples
        List of interval bounds
    
    Returns
    -------
    dict
        Summary statistics
    """
    
    stats = {
        "total_intervals": len(intervals),
        "max_probability_global": 0,
        "mean_probability": [],
        "interval_ranges": []
    }
    
    for idx, prob_grid in enumerate(prob_grids):
        max_prob = float(prob_grid.max())
        mean_prob = float(prob_grid.mean())
        
        stats["max_probability_global"] = max(stats["max_probability_global"], max_prob)
        stats["mean_probability"].append(mean_prob)
        
        start, end = intervals[idx]
        stats["interval_ranges"].append({
            "interval": f"{start}-{end}h",
            "max_probability": round(max_prob, 4),
            "mean_probability": round(mean_prob, 4),
            "grid_size": prob_grid.shape
        })
    
    return stats


if __name__ == "__main__":
    """
    Quick test of PDF generation
    """
    print("PDF Report Generator - SARAT v3")
    print("=" * 50)
    
    # Test parameters
    test_output = "."
    test_case = "6687"
    test_intervals = [(0, 24), (24, 48), (48, 72)]
    test_info = {
        "num_trajectories": 500,
        "grid_size": 0.1,
        "description": "Test case for PDF generation"
    }
    
    # Note: PDF generation will fail without actual PNG files
    print("PDF generation requires PNG images to be present.")
    print(f"Would generate: sarat_report_{test_case}.pdf")
    print(f"With {len(test_intervals)} intervals")
