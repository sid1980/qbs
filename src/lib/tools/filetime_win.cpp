/**************************************************************************
**
** This file is part of the Qt Build Suite
**
** Copyright (c) 2012 Nokia Corporation and/or its subsidiary(-ies).
**
** Contact: Nokia Corporation (info@qt.nokia.com)
**
**
** GNU Lesser General Public License Usage
**
** This file may be used under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation and
** appearing in the file LICENSE.LGPL included in the packaging of this file.
** Please review the following information to ensure the GNU Lesser General
** Public License version 2.1 requirements will be met:
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights. These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU General
** Public License version 3.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of this
** file.
** Please review the following information to ensure the GNU General
** Public License version 3.0 requirements will be met:
** http://www.gnu.org/copyleft/gpl.html.
**
** Other Usage
** Alternatively, this file may be used in accordance with the terms and
** conditions contained in a signed written agreement between you and Nokia.
**
**************************************************************************/

#include "filetime.h"

#include <QtCore/QString>
#include <qt_windows.h>
#ifdef Q_CC_MSVC
#include <strsafe.h>
#endif // Q_CC_MSVC

template<bool> struct CompileTimeAssert;
template<> struct CompileTimeAssert<true> {};
static CompileTimeAssert<sizeof(qbs::FileTime::InternalType) == sizeof(FILETIME)> internal_type_has_wrong_size;

namespace qbs {

FileTime::FileTime()
    : m_fileTime(0)
{
}

bool FileTime::operator < (const FileTime &rhs) const
{
    const FILETIME *const t1 = reinterpret_cast<const FILETIME *>(&m_fileTime);
    const FILETIME *const t2 = reinterpret_cast<const FILETIME *>(&rhs.m_fileTime);
    return CompareFileTime(t1, t2) < 0;
}

void FileTime::clear()
{
    m_fileTime = 0;
}

bool FileTime::isValid() const
{
    return m_fileTime != 0;
}

FileTime FileTime::currentTime()
{
    FileTime result;
    SYSTEMTIME st;
    GetSystemTime(&st);
    FILETIME *const ft = reinterpret_cast<FILETIME *>(&result.m_fileTime);
    SystemTimeToFileTime(&st, ft);
    return result;
}

QString FileTime::toString() const
{
    const FILETIME *const ft = reinterpret_cast<const FILETIME *>(&m_fileTime);
    SYSTEMTIME stUTC, stLocal;
    FileTimeToSystemTime(ft, &stUTC);
    SystemTimeToTzSpecificLocalTime(NULL, &stUTC, &stLocal);
#ifdef Q_CC_MSVC
    WCHAR szString[512];
    HRESULT hr = StringCchPrintf(szString, sizeof(szString) / sizeof(WCHAR),
                                 L"%02d.%02d.%d %02d:%02d:%02d",
                                 stLocal.wDay, stLocal.wMonth, stLocal.wYear,
                                 stLocal.wHour, stLocal.wMinute, stLocal.wSecond);
    return SUCCEEDED(hr) ? QString::fromUtf16(szString) : QString();
#else // Q_CC_MSVC
    const QString result = QString("%1.%2.%3 %4:%5:%6")
            .arg(stLocal.wDay, 2, 10, QLatin1Char('0')).arg(stLocal.wMonth, 2, 10, QLatin1Char('0')).arg(stLocal.wYear)
            .arg(stLocal.wHour, 2, 10, QLatin1Char('0')).arg(stLocal.wMinute, 2, 10, QLatin1Char('0')).arg(stLocal.wSecond, 2, 10, QLatin1Char('0'));
    return result;
#endif // Q_CC_MSVC
}
}
