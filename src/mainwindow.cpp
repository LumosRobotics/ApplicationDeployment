#include "mainwindow.h"
#include <QVBoxLayout>
#include <QWidget>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("Qt Application Deployment Example");
    setMinimumSize(400, 300);
    
    QWidget *centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    
    QVBoxLayout *layout = new QVBoxLayout(centralWidget);
    
    label = new QLabel("Qt Application Deployment System\n\nThis is an example application for testing deployment.", this);
    label->setAlignment(Qt::AlignCenter);
    label->setStyleSheet("font-size: 14px; padding: 20px;");
    
    layout->addWidget(label);
}

MainWindow::~MainWindow()
{
}